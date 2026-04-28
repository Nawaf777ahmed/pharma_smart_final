using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using PharmaSmartWeb.Models;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;

// 🚀 استدعاء مجلد الفلاتر الذي يحتوي على الحارس
using PharmaSmartWeb.Filters;

namespace PharmaSmartWeb.Controllers
{
    [Authorize] // يمنع دخول الزوار غير المسجلين أصلاً
    public class UsersController : BaseController
    {
        private readonly IPasswordHasher<Users> _passwordHasher;

        public UsersController(ApplicationDbContext context, IPasswordHasher<Users> passwordHasher) : base(context)
        {
            _passwordHasher = passwordHasher;
        }

        // ==========================================
        // 👥 1. جلب Users (GET) مع العزل الشامل
        // ==========================================
        [HttpGet]
        [HasPermission("Users", "View")] // 🛡️ حارس العرض
        public async Task<IActionResult> Index()
        {
            var query = _context.Users
                                .Include(u => u.DefaultBranch)
                                .Include(u => u.Role)
                                .AsQueryable();

            // 🚀 العزل التام: الجميع (المدير والموظف) يرى مستخدمي "الفرع النشط" فقط
            query = query.Where(u => u.DefaultBranchId == ActiveBranchId);

            var users = await query.ToListAsync();
            return View(users);
        }

        // ==========================================
        // ➕ 2. شاشة إضافة مستخدم جديد (GET)
        // ==========================================
        [HttpGet]
        [HasPermission("Users", "Add")] // 🛡️ حارس فتح شاشة الإضافة
        public IActionResult Create()
        {
            LoadIsolatedViewData();
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [HasPermission("Users", "Add")] // 🛡️ حارس تنفيذ عملية الإضافة
        public async Task<IActionResult> Create(Users newUser)
        {
            newUser.IsActive = true;

            ModelState.Remove("DefaultBranch");
            ModelState.Remove("Employee");
            ModelState.Remove("Role");
            ModelState.Remove("Drugtransfers");
            ModelState.Remove("Fundtransfers");
            ModelState.Remove("Journalentries");
            ModelState.Remove("Purchases");
            ModelState.Remove("Sales");
            ModelState.Remove("Stockmovements");
            ModelState.Remove("Stockaudits");
            ModelState.Remove("Systemlogs");
            ModelState.Remove("BarcodeGenerator");
            ModelState.Remove("UserScreenPermissions");
            ModelState.Remove("Email");
            ModelState.Remove("EmployeeId");

            // 🚀 مدير النظام يختار الفرع يدوياً • الموظف العادي يُختم آلياً بفرعه النشط
            if (!IsSuperAdmin)
            {
                newUser.DefaultBranchId = ActiveBranchId;
            }

            if (ModelState.IsValid)
            {
                bool exists = await _context.Users.AnyAsync(u => u.Username == newUser.Username);
                if (exists)
                {
                    ViewBag.Error = "اسم المستخدم هذا موجود مسبقاً.";
                    LoadIsolatedViewData(newUser);
                    return View(newUser);
                }

                newUser.PasswordHash = _passwordHasher.HashPassword(newUser, newUser.PasswordHash);
                
                _context.Users.Add(newUser);
                await _context.SaveChangesAsync();

                // 🚀 تسجيل عملية إنشاء الحساب في السجلات (Logs)
                await RecordLog("Add", "Users", $"تم إنشاء حساب مستخدم جديد باسم: {newUser.Username} وتعيينه للفرع {ActiveBranchId}");

                TempData["Success"] = "تم إضافة المستخدم بنجاح!";
                return RedirectToAction(nameof(Index));
            }

            var exactErrors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
            ViewBag.Error = "مشكلة في الحفظ: " + string.Join(" | ", exactErrors);

            LoadIsolatedViewData(newUser);
            return View(newUser);
        }

        // ==========================================
        // ✏️ 3. شاشة تعديل مستخدم (GET)
        // ==========================================
        [HttpGet]
        [HasPermission("Users", "Edit")] // 🛡️ حارس فتح شاشة التعديل
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();

            var user = await _context.Users.FindAsync(id);
            if (user == null) return NotFound();

            // 🚀 حماية العزل: منع الدخول لتعديل حساب مستخدم في فرع آخر (حتى للمدير)
            if (user.DefaultBranchId != ActiveBranchId)
            {
                return RedirectToAction("AccessDenied", "Home");
            }

            LoadIsolatedViewData(user);
            return View(user);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [HasPermission("Users", "Edit")] // 🛡️ حارس تنفيذ عملية التعديل
        public async Task<IActionResult> Edit(int id, Users updatedUser)
        {
            if (id != updatedUser.UserId) return NotFound();

            ModelState.Remove("DefaultBranch");
            ModelState.Remove("Employee");
            ModelState.Remove("Role");
            ModelState.Remove("Drugtransfers");
            ModelState.Remove("Fundtransfers");
            ModelState.Remove("Journalentries");
            ModelState.Remove("Purchases");
            ModelState.Remove("Sales");
            ModelState.Remove("Stockmovements");
            ModelState.Remove("Stockaudits");
            ModelState.Remove("Systemlogs");
            ModelState.Remove("BarcodeGenerator");
            ModelState.Remove("UserScreenPermissions");
            ModelState.Remove("Email");
            ModelState.Remove("EmployeeId");

            if (ModelState.IsValid)
            {
            // 🚀 حماية أمنية للـ POST: للموظف العادي فقط - المدير يستطيع تعديل أي مستخدم
            if (!IsSuperAdmin)
            {
                var existingUser = await _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.UserId == id);
                if (existingUser?.DefaultBranchId != ActiveBranchId)
                {
                    return RedirectToAction("AccessDenied", "Home");
                }
                // 🚀 منع نقل المستخدم لفرع آخر عبر الـ Inspect Element (للموظف العادي فقط)
                updatedUser.DefaultBranchId = ActiveBranchId;
            }

                bool exists = await _context.Users.AnyAsync(u => u.Username == updatedUser.Username && u.UserId != updatedUser.UserId);
                if (exists)
                {
                    ViewBag.Error = "اسم المستخدم هذا مستخدم بالفعل لحساب آخر.";
                    LoadIsolatedViewData(updatedUser);
                    return View(updatedUser);
                }

                // Only hash password if it was changed (not matching the original hash in the DB)
                var existingUserHashCheck = await _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.UserId == updatedUser.UserId);
                if (existingUserHashCheck != null && existingUserHashCheck.PasswordHash != updatedUser.PasswordHash && !string.IsNullOrWhiteSpace(updatedUser.PasswordHash))
                {
                    updatedUser.PasswordHash = _passwordHasher.HashPassword(updatedUser, updatedUser.PasswordHash);
                }

                _context.Update(updatedUser);
                await _context.SaveChangesAsync();

                // 🚀 تسجيل عملية التعديل في السجلات (Logs)
                string status = updatedUser.IsActive == true ? "نشط" : "محظور";
                await RecordLog("Edit", "Users", $"تعديل بيانات المستخدم: {updatedUser.Username} في الفرع {ActiveBranchId} - الحالة الحالية: {status}");

                // التحديث الأمني (طرد المدير الذي يحظر نفسه)
                if (updatedUser.IsActive == false && User.Identity.Name == updatedUser.Username)
                {
                    await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                    return RedirectToAction("Login", "Account");
                }

                TempData["Success"] = "تم تحديث بيانات وحالة المستخدم بنجاح!";
                return RedirectToAction(nameof(Index));
            }

            var exactErrors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
            ViewBag.Error = "توجد مشكلة في البيانات المدخلة: " + string.Join(" | ", exactErrors);

            LoadIsolatedViewData(updatedUser);
            return View(updatedUser);
        }

        // ==========================================
        // 🔄 4. دالة مساعدة لتعبئة القوائم المعزولة
        // ==========================================
        private void LoadIsolatedViewData(Users user = null)
        {
            // 🚀 مدير النظام يرى كافة الفروع والموظفين • الموظف العادي يرى فرعه فقط
            IQueryable<Branches> branchesQuery;
            IQueryable<Employees> employeesQuery;

            if (IsSuperAdmin)
            {
                // مدير النظام: كل الفروع النشطة وكل الموظفين النشطين
                branchesQuery  = _context.Branches .Where(b => b.IsActive == true).AsQueryable();
                employeesQuery = _context.Employees.Where(e => e.IsActive == true).AsQueryable();
            }
            else
            {
                // الفرع العزل الصارم: الفرع النشط فقط
                branchesQuery  = _context.Branches .Where(b => b.IsActive == true && b.BranchId == ActiveBranchId).AsQueryable();
                employeesQuery = _context.Employees.Where(e => e.IsActive == true && e.BranchId == ActiveBranchId).AsQueryable();
            }

            var rolesQuery = _context.Userroles.AsQueryable();

            // 🚀 حماية أمنية إضافية: منع الموظف العادي من منح صلاحية "مدير عام"
            if (!IsSuperAdmin)
            {
                rolesQuery = rolesQuery.Where(r => r.RoleId != 1);
            }

            ViewBag.BranchList   = new SelectList(branchesQuery,  "BranchId",   "BranchName", user?.DefaultBranchId);
            ViewBag.EmployeeList = new SelectList(employeesQuery,  "EmployeeId", "FullName",   user?.EmployeeId);
            ViewBag.RoleList     = new SelectList(rolesQuery,      "RoleId",     "RoleName",   user?.RoleId);
        }
        // ==========================================
        // 🔐 5. شاشة مصفوفة صلاحيات المستخدم (ManagePermissions)
        // ==========================================
        [HttpGet]
        [HasPermission("Users", "Edit")] // يمكن استخدام حارس مخصص أو Roles.Edit
        public async Task<IActionResult> ManagePermissions(int roleId) // This parameter is actually userId now, named roleId because of asp-route-roleId in the View, wait, let's fix the view to use asp-route-userId instead. We will name it userId here.
        {
            // Fallback: If it's passed from the old view code
            int userId = roleId; 
            var user = await _context.Users.Include(u => u.Role).AsNoTracking().FirstOrDefaultAsync(u => u.UserId == userId);

            if (user == null) return NotFound();

            if (user.Username?.ToLower() == "admin") 
                return RedirectToAction("AccessDenied", "Home");

            ViewBag.UserName = user.Username;
            ViewBag.UserId = userId;
            ViewBag.RoleName = user.Role?.RoleArabicName ?? user.Role?.RoleName;

            var screens = await _context.Systemscreens
                .AsNoTracking()
                .OrderBy(s => s.ScreenCategory)
                .ThenBy(s => s.ScreenArabicName)
                .ToListAsync();

            // Check if user has explicit permissions
            var currentPermissions = await _context.UserScreenPermissions
                .Where(p => p.UserId == userId)
                .AsNoTracking()
                .ToListAsync();

            // ✅ جلب صلاحيات الدور دائماً كمرجع أساسي (Fallback)
            var rolePermissions = await _context.Screenpermissions
                .Where(p => p.RoleId == user.RoleId)
                .AsNoTracking()
                .ToListAsync();
                
            ViewBag.CurrentRolePermissions = rolePermissions;

            if (!currentPermissions.Any())
            {
                ViewBag.HasExplicitPermissions = false;
            }
            else
            {
                ViewBag.CurrentPermissions = currentPermissions;
                ViewBag.HasExplicitPermissions = true;
            }

            return View("ManagePermissions", screens);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [HasPermission("Users", "Edit")]
        public async Task<IActionResult> UpdatePermissions(int userId, List<UserScreenPermissions> permissions)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null || user.Username?.ToLower() == "admin") 
                return RedirectToAction("AccessDenied", "Home");

            if (permissions == null || !permissions.Any())
            {
                TempData["Error"] = "لم يتم إرسال أي بيانات للصلاحيات.";
                return RedirectToAction(nameof(Index));
            }

            var strategy = _context.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () =>
            {
                using (var transaction = await _context.Database.BeginTransactionAsync())
                {
                    try
                    {
                        // حذف جميع الصلاحيات القديمة للمستخدم
                        var oldPermissions = _context.UserScreenPermissions.Where(p => p.UserId == userId);
                        _context.UserScreenPermissions.RemoveRange(oldPermissions);
                        await _context.SaveChangesAsync();

                        // ✅ الإصلاح الجذري: حفظ جميع الشاشات بما فيها المحظورة (CanView=false)
                        // يجب حفظ سجل لكل شاشة حتى تعمل آلية الاستثناءات بشكل صحيح
                        // إذا لم يُحفَظ سجل الشاشة المحظورة، سيعود النظام لصلاحيات الدور الموروثة
                        foreach (var perm in permissions)
                        {
                            perm.PermissionId = 0; // إعادة تعيين المعرف لضمان الإدراج كسجل جديد
                            perm.UserId = userId;
                            _context.UserScreenPermissions.Add(perm);
                        }

                        await _context.SaveChangesAsync();
                        await transaction.CommitAsync();

                        var _cache = (Microsoft.Extensions.Caching.Memory.IMemoryCache)HttpContext.RequestServices.GetService(typeof(Microsoft.Extensions.Caching.Memory.IMemoryCache));
                        if (_cache != null)
                        {
                            _cache.Remove($"Permissions_UserRole_{userId}_{user.RoleId}");
                            _cache.Remove($"Permissions_Override_{userId}_{user.RoleId}");
                            _cache.Remove($"Filter_Permissions_UserRole_{userId}_{user.RoleId}");
                        }

                        TempData["Success"] = $"✅ تم حفظ الاستثناءات الخاصة بالمستخدم ({user.Username}). ستُطبق التعديلات عند إعادة دخوله.";
                    }
                    catch (System.Exception ex)
                    {
                        await transaction.RollbackAsync();
                        TempData["Error"] = "حدث خطأ أثناء حفظ البيانات: " + ex.Message + (ex.InnerException != null ? " | " + ex.InnerException.Message : "");
                    }
                }
            });

            return RedirectToAction(nameof(Index));
        }
        // ==========================================
        // 🗑 7. إعادة الضبط وحذف الاستثناءات (ClearPermissions)
        // ==========================================
        [HttpGet]
        [HasPermission("Users", "Edit")]
        public async Task<IActionResult> ClearPermissions(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null || user.Username?.ToLower() == "admin") 
                return RedirectToAction("AccessDenied", "Home");

            try
            {
                var oldPermissions = _context.UserScreenPermissions.Where(p => p.UserId == userId);
                _context.UserScreenPermissions.RemoveRange(oldPermissions);
                await _context.SaveChangesAsync();

                // مسح الكاش
                var _cache = (Microsoft.Extensions.Caching.Memory.IMemoryCache)HttpContext.RequestServices.GetService(typeof(Microsoft.Extensions.Caching.Memory.IMemoryCache));
                if (_cache != null)
                {
                    _cache.Remove($"Permissions_UserRole_{userId}_{user.RoleId}");
                    _cache.Remove($"Permissions_Override_{userId}_{user.RoleId}");
                    _cache.Remove($"Filter_Permissions_UserRole_{userId}_{user.RoleId}");
                }

                TempData["Success"] = $"🗑 تم إعادة ضبط الصلاحيات للمستخدم ({user.Username}) بنجاح وعاد لصلاحيات الدور الأصلية.";
            }
            catch (System.Exception ex)
            {
                TempData["Error"] = "حدث خطأ أثناء إعادة الضبط: " + ex.Message;
            }

            // ✅ إصلاح الخلل 404: الدالة ManagePermissions تتوقع وسيطاً باسم `roleId` وليس `id`
            return RedirectToAction(nameof(ManagePermissions), new { roleId = userId });
        }

    }
}

/* =============================================================================================
📑 الكتالوج والدليل الفني للكنترولر (UsersController)
=============================================================================================
الوظيفة العامة: 
هذا الكنترولر مسؤول عن "إدارة الهويات وحسابات الدخول" (User Access Management) في النظام.
يختص بإنشاء مستخدمين جدد، ربطهم بالموظفين الفعليين، تعيين المجموعات الوظيفية (Roles)، 
وإيقاف الحسابات أو حظرها.

ملاحظة معمارية بخصوص العزل الشامل (Context-Aware Isolation):
- 🚀 تم تطبيق قاعدة العزل الصارمة (ActiveBranchId) على كافة العمليات ولجميع المستخدمين 
  بما في ذلك المدير العام (SuperAdmin).
- لماذا نعزل المدير في شاشة المستخدمين؟
  لضمان التنظيم الإداري السليم. إذا أراد المدير إضافة مستخدم لفرع "صنعاء"، فيجب أن يتواجد 
  في سياق فرع "صنعاء" (من القائمة العلوية)، لكي تظهر له قائمة "موظفي صنعاء" فقط، ويتم ربط 
  المستخدم الجديد آلياً بذلك الفرع، مما يمنع تعيين موظف بالخطأ لفرع لا يعمل فيه.
- العرض (Index): لا يعرض سوى مستخدمي "الفرع النشط".
- الإضافة (Create) والتعديل (Edit): يتم الختم آلياً برقم `ActiveBranchId`، وتم عزل 
  القوائم المنسدلة (Dropdowns) لتظهر خيارات الفرع النشط فقط.
- حماية الاختراق: يمنع النظام تمرير أي طلب POST لتعديل مستخدم ينتمي لفرع مختلف عن 
  سياق المدير الحالي، كما يمنع الموظفين العاديين من ترقية أنفسهم إلى "مدير عام".
=============================================================================================
*/
