using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using PharmaSmartWeb.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using PharmaSmartWeb.Security;

namespace PharmaSmartWeb.Filters
{
    public class HasPermissionAttribute : TypeFilterAttribute
    {
        public HasPermissionAttribute(string screenName, string action)
            : base(typeof(PermissionFilter))
        {
            Arguments = new object[] { screenName, action };
        }
    }

    public class PermissionFilter : IAsyncAuthorizationFilter
    {
        private readonly string _screenName;
        private readonly string _action;
        private readonly ApplicationDbContext _db;
        private readonly IMemoryCache _cache;

        public PermissionFilter(string screenName, string action, ApplicationDbContext db, IMemoryCache cache)
        {
            _screenName = screenName;
            _action = action;
            _db = db;
            _cache = cache;
        }

        public async Task OnAuthorizationAsync(AuthorizationFilterContext context)
        {
            var user = context.HttpContext.User;

            if (!user.Identity.IsAuthenticated)
            {
                context.Result = new RedirectToActionResult("Login", "Account", null);
                return;
            }

            var roleIdStr = user.FindFirst("RoleID")?.Value ?? user.FindFirst("RoleId")?.Value;
            // إصلاح: AccountController يخزن UserID وليس ClaimTypes.NameIdentifier
            var userIdStr = user.FindFirst("UserID")?.Value ?? user.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(roleIdStr) || !int.TryParse(roleIdStr, out int roleId))
            {
                context.Result = new RedirectToActionResult("AccessDenied", "Home", null);
                return;
            }

            // استخراج userId بشكل آمن - إذا لم يوجد نستخدم 0 كقيمة افتراضية
            int.TryParse(userIdStr, out int userId);

            if (roleId == 1)
            {
                return; // الخروج من الفلتر والسماح بالوصول
            }

            string cacheKey = $"Filter_Permissions_UserRole_{userId}_{roleId}";

            if (!_cache.TryGetValue(cacheKey, out List<CachedPermission> rolePermissions))
            {
                try
                {
                    // تحقق أولاً من الصلاحيات الاستثنائية للمستخدم
                    var userPermissions = await _db.UserScreenPermissions
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
                        rolePermissions = userPermissions;
                    }
                    else
                    {
                        // جلب الصلاحيات الموروثة من الدور
                        rolePermissions = await _db.Screenpermissions
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

                    var cacheOptions = new MemoryCacheEntryOptions()
                        .SetSlidingExpiration(TimeSpan.FromMinutes(30));

                    _cache.Set(cacheKey, rolePermissions, cacheOptions);
                }
                catch (Exception)
                {
                    // الحماية القصوى: توجيه المستخدم لصفحة منع الوصول بدلاً من الشاشة البيضاء المخيفة
                    context.Result = new RedirectToActionResult("AccessDenied", "Home", null);
                    return;
                }
            }

            bool hasAccess = false;
            var targetPermission = rolePermissions?.FirstOrDefault(p => p.ScreenName == _screenName);

            if (targetPermission != null)
            {
                hasAccess = _action switch
                {
                    "View" => targetPermission.CanView,
                    "Add" => targetPermission.CanAdd,
                    "Edit" => targetPermission.CanEdit,
                    "Delete" => targetPermission.CanDelete,
                    _ => false
                };
            }

            if (!hasAccess)
            {
                context.Result = new RedirectToActionResult("AccessDenied", "Home", null);
            }
        }
    }
}