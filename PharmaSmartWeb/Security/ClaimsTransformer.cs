using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;
using PharmaSmartWeb.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace PharmaSmartWeb.Security
{
    // 🚀 كائن بسيط جداً لمنع انهيار EF Core
    public class CachedPermission
    {
        public string ScreenName { get; set; }
        public bool CanView { get; set; }
        public bool CanAdd { get; set; }
        public bool CanEdit { get; set; }
        public bool CanDelete { get; set; }
    }

    public class ClaimsTransformer : IClaimsTransformation
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly IMemoryCache _cache;

        public ClaimsTransformer(IServiceProvider serviceProvider, IMemoryCache cache)
        {
            _serviceProvider = serviceProvider;
            _cache = cache;
        }

        public async Task<ClaimsPrincipal> TransformAsync(ClaimsPrincipal principal)
        {
            var identity = principal.Identity as ClaimsIdentity;
            if (identity == null || !identity.IsAuthenticated) return principal;

            if (principal.HasClaim(c => c.Type == "PermissionsLoaded")) return principal;

            var clone = principal.Clone();
            var newIdentity = (ClaimsIdentity)clone.Identity;

            var roleIdStr = principal.FindFirst("RoleID")?.Value ?? principal.FindFirst("RoleId")?.Value;
            // إصلاح: AccountController يخزن UserID وليس ClaimTypes.NameIdentifier
            var userIdStr = principal.FindFirst("UserID")?.Value ?? principal.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

            if (int.TryParse(roleIdStr, out int roleId) && int.TryParse(userIdStr, out int userId))
            {
                string cacheKey = $"Permissions_UserRole_{userId}_{roleId}";
                string overrideCacheKey = $"Permissions_Override_{userId}_{roleId}";
                bool isOverride = false;

                if (!_cache.TryGetValue(cacheKey, out List<CachedPermission> rolePermissions))
                {
                    try
                    {
                        using (var scope = _serviceProvider.CreateScope())
                        {
                            var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

                            if (roleId == 1)
                            {
                                // المدير العام يحصل على كافة الصلاحيات لكل الشاشات
                                rolePermissions = await db.Systemscreens
                                    .Select(s => new CachedPermission
                                    {
                                        ScreenName = s.ScreenName,
                                        CanView = true,
                                        CanAdd = true,
                                        CanEdit = true,
                                        CanDelete = true
                                    })
                                    .ToListAsync();
                            }
                            else
                            {
                                // تحقق أولاً مما إذا كان لدى المستخدم صلاحيات استثنائية
                                var userPermissions = await db.UserScreenPermissions
                                    .Where(p => p.UserId == userId && p.Screen != null)
                                    .Select(p => new CachedPermission
                                    {
                                        ScreenName = p.Screen.ScreenName,
                                        CanView = p.CanView,
                                        CanAdd = p.CanAdd,
                                        CanEdit = p.CanEdit,
                                        CanDelete = p.CanDelete
                                    })
                                    .ToListAsync();

                                if (userPermissions != null && userPermissions.Count > 0)
                                {
                                    rolePermissions = userPermissions; // استخدام صلاحيات المستخدم الفردية
                                    isOverride = true;
                                }
                                else
                                {
                                    // 🚀 جلب الصلاحيات الموروثة من الدور
                                    rolePermissions = await db.Screenpermissions
                                        .Where(p => p.RoleId == roleId && p.Screen != null)
                                        .Select(p => new CachedPermission
                                        {
                                            ScreenName = p.Screen.ScreenName,
                                            CanView = p.CanView,
                                            CanAdd = p.CanAdd,
                                            CanEdit = p.CanEdit,
                                            CanDelete = p.CanDelete
                                        })
                                        .ToListAsync();
                                }
                            }
                        }

                        if (rolePermissions != null && rolePermissions.Count > 0)
                        {
                            // ✅ الإصلاح: تقليل مدة كاش الصلاحيات من 12 ساعة إلى 30 دقيقة
                            _cache.Set(cacheKey, rolePermissions, TimeSpan.FromMinutes(30));
                            _cache.Set(overrideCacheKey, isOverride, TimeSpan.FromMinutes(30));
                        }
                    }
                    catch (Exception)
                    {
                        rolePermissions = new List<CachedPermission>();
                    }
                }
                else
                {
                    // استرجاع هل هو استثناء أم لا من الكاش
                    _cache.TryGetValue(overrideCacheKey, out isOverride);
                }

                // زرع الصلاحيات لكي تظهر الأزرار
                if (rolePermissions != null && rolePermissions.Count > 0)
                {
                    if (isOverride)
                    {
                        newIdentity.AddClaim(new Claim("HasUserPermissionOverride", "true"));
                    }

                    var uniquePermissions = rolePermissions.GroupBy(p => p.ScreenName).Select(g => g.First());
                    foreach (var p in uniquePermissions)
                    {
                        if (p.CanView) newIdentity.AddClaim(new Claim("Permission", $"{p.ScreenName}.View"));
                        if (p.CanAdd) newIdentity.AddClaim(new Claim("Permission", $"{p.ScreenName}.Add"));
                        if (p.CanEdit) newIdentity.AddClaim(new Claim("Permission", $"{p.ScreenName}.Edit"));
                        if (p.CanDelete) newIdentity.AddClaim(new Claim("Permission", $"{p.ScreenName}.Delete"));
                    }
                }
            }

            newIdentity.AddClaim(new Claim("PermissionsLoaded", "true"));
            return clone;
        }
    }
}