//using Microsoft.AspNetCore.Mvc;
//using Microsoft.EntityFrameworkCore;
//using PharmaSmartWeb.Models;
//using System.Threading.Tasks;
//using Microsoft.AspNetCore.Authorization;
//using System.Security.Claims;
//using System.Collections.Generic;
//using Microsoft.AspNetCore.Authentication;
//using Microsoft.AspNetCore.Authentication.Cookies;
//using System.Linq;
//using System;

//namespace PharmaSmartWeb.Controllers
//{
//    // 🚀 يرث من BaseController للوصول لمحرك العزل وخدمة RecordLog
//    public class AccountController : BaseController
//    {
//        public AccountController(ApplicationDbContext context) : base(context)
//        {
//        }

//        // ==========================================
//        // 1. شاشة تسجيل الدخول (GET)
//        // ==========================================
//        [HttpGet]
//        // 🛡️ الحل التقني: منع الكاش يضمن توليد مفتاح أمان (CSRF Token) جديد دائماً ويحل مشكلة "النقرة الثانية"
//        [ResponseCache(Location = ResponseCacheLocation.None, NoStore = true)]
//        public async Task<IActionResult> Login(string returnUrl = null)
//        {
//            // 🚀 العزل الأمني: مسح أي كوكيز قديمة (بما فيها ActiveBranchId) فور فتح الصفحة لضمان بيئة نظيفة 100%
//            if (User.Identity.IsAuthenticated || Request.Cookies.Count > 0)
//            {
//                foreach (var cookie in Request.Cookies.Keys)
//                {
//                    Response.Cookies.Delete(cookie);
//                }
//                await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
//            }

//            // تنظيف الرابط من أي مخلفات أخطاء سابقة
//            if (returnUrl != null && returnUrl.Contains("HandleError")) returnUrl = null;

//            ViewData["ReturnUrl"] = returnUrl;
//            return View();
//        }

//        // ==========================================
//        // 2. معالجة عملية تسجيل الدخول (POST)
//        // ==========================================
//        [HttpPost]
//        [ValidateAntiForgeryToken]
//        public async Task<IActionResult> Login(string username, string password, string returnUrl = null)
//        {
//            if (string.IsNullOrEmpty(username)) return View();

//            // 🚀 الإجراء الوقائي: مسح المسافات الفارغة (Trim) لحل مشاكل الإدخال
//            string cleanUsername = username.Trim();

//            // 1. التحقق من المستخدم في قاعدة البيانات
//            var user = await _context.Users
//                .FirstOrDefaultAsync(u => u.Username == cleanUsername && u.PasswordHash == password);

//            if (user == null || user.IsActive == false)
//            {
//                ViewBag.Error = "اسم المستخدم أو كلمة المرور غير صحيحة، أو الحساب محظور.";
//                return View();
//            }

//            // 2. جلب اسم الدور واسم الفرع بشكل آمن ومنفصل لضمان استقرار الربط
//            string roleName = "User";
//            if (user.RoleId > 0)
//            {
//                var role = await _context.Userroles.AsNoTracking().FirstOrDefaultAsync(r => r.RoleId == user.RoleId);
//                roleName = role?.RoleArabicName ?? role?.RoleName ?? "User";
//            }

//            string branchName = "فرع غير محدد";
//            if (user.DefaultBranchId > 0)
//            {
//                var branch = await _context.Branches.AsNoTracking().FirstOrDefaultAsync(b => b.BranchId == user.DefaultBranchId);
//                branchName = branch?.BranchName ?? "فرع غير محدد";
//            }

//            // 3. بناء الهوية البرمجية (Claims)
//            var claims = new List<Claim>
//            {
//                new Claim(ClaimTypes.Name, user.Username),
//                new Claim("UserID", user.UserId.ToString()),
//                new Claim("RoleID", user.RoleId.ToString()),
//                new Claim("RoleName", roleName),

//                // 🚀 تأسيس العزل: الفرع الافتراضي للموظف، ونقطة البداية للمدير
//                new Claim("BranchID", user.DefaultBranchId?.ToString() ?? "1"),
//                new Claim("BranchName", branchName)
//            };

//            // 4. 🚀 محرك الصلاحيات الفوري:
//            // جلب كافة الصلاحيات وزرعها في الكوكي لكي تظهر الأزرار في القائمة الجانبية فوراً
//            var permissions = await _context.Screenpermissions
//                .Include(p => p.Screen)
//                .Where(p => p.RoleId == user.RoleId)
//                .AsNoTracking()
//                .ToListAsync();

//            foreach (var p in permissions)
//            {
//                if (p.CanView) claims.Add(new Claim("Permission", $"{p.Screen.ScreenName}.View"));
//                if (p.CanAdd) claims.Add(new Claim("Permission", $"{p.Screen.ScreenName}.Add"));
//                if (p.CanEdit) claims.Add(new Claim("Permission", $"{p.Screen.ScreenName}.Edit"));
//                if (p.CanDelete) claims.Add(new Claim("Permission", $"{p.Screen.ScreenName}.Delete"));
//                if (p.CanPrint) claims.Add(new Claim("Permission", $"{p.Screen.ScreenName}.Print"));
//            }

//            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

//            var authProperties = new AuthenticationProperties
//            {
//                IsPersistent = true, // تذكرني
//                ExpiresUtc = DateTimeOffset.UtcNow.AddHours(12) // صلاحية الجلسة
//            };

//            await HttpContext.SignInAsync(
//                CookieAuthenticationDefaults.AuthenticationScheme,
//                new ClaimsPrincipal(claimsIdentity),
//                authProperties);

//            // 🛡️ توثيق عملية الدخول في سجلات الرقابة (عبر الموتور المورث من BaseController)
//            // نمرر ActiveBranchId الافتراضي الذي تم تأسيسه للتو
//            await RecordLog("Login", "Account", $"المستخدم {user.Username} سجل دخوله بنجاح من {branchName}.");

//            // التوجيه الذكي
//            if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl) && !returnUrl.Contains("HandleError"))
//            {
//                return Redirect(returnUrl);
//            }

//            return RedirectToAction("Index", "Home");
//        }

//        // ==========================================
//        // 3. دالة تسجيل الخروج 
//        // ==========================================
//        [HttpGet]
//        public async Task<IActionResult> Logout()
//        {
//            if (User.Identity.IsAuthenticated)
//            {
//                await RecordLog("Logout", "Account", "قام المستخدم بتسجيل الخروج بنجاح.");
//            }

//            // 🚀 العزل الأمني: تدمير كوكي "الفرع النشط" لكي لا يرثه من يستخدم الجهاز لاحقاً
//            Response.Cookies.Delete("ActiveBranchId");

//            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
//            return RedirectToAction("Login", "Account");
//        }

//        // ==========================================
//        // 4. تغيير كلمة المرور
//        // ==========================================
//        [Authorize]
//        [HttpGet]
//        public IActionResult ChangePassword() => View();

//        [Authorize]
//        [HttpPost]
//        [ValidateAntiForgeryToken]
//        public async Task<IActionResult> ChangePassword(string currentPassword, string newPassword, string confirmPassword)
//        {
//            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == User.Identity.Name);
//            if (user == null || user.PasswordHash != currentPassword)
//            {
//                ViewBag.Error = "كلمة المرور الحالية غير صحيحة!";
//                return View();
//            }

//            if (newPassword != confirmPassword)
//            {
//                ViewBag.Error = "كلمة المرور الجديدة غير متطابقة!";
//                return View();
//            }

//            user.PasswordHash = newPassword;
//            _context.Update(user);
//            await _context.SaveChangesAsync();

//            await RecordLog("Update", "Account", "تم تغيير كلمة المرور بنجاح.");
//            return RedirectToAction("Index", "Home");
//        }
//    }
//}
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PharmaSmartWeb.Models;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Identity;
using System.Linq;
using System;
using Microsoft.Extensions.Caching.Memory;

namespace PharmaSmartWeb.Controllers
{
    // 🚀 يرث من BaseController للوصول لمحرك العزل وخدمة RecordLog
    public class AccountController : BaseController
    {
        private readonly IPasswordHasher<Users> _passwordHasher;
        private readonly IMemoryCache _cache;
        private readonly PharmaSmartWeb.Services.IWhatsAppService _whatsappService;
        private readonly IConfiguration _configuration;

        public AccountController(
            ApplicationDbContext context, 
            IPasswordHasher<Users> passwordHasher,
            IMemoryCache cache,
            PharmaSmartWeb.Services.IWhatsAppService whatsappService,
            IConfiguration configuration) : base(context)
        {
            _passwordHasher = passwordHasher;
            _cache = cache;
            _whatsappService = whatsappService;
            _configuration = configuration;
        }

        // ==========================================
        // 1. شاشة تسجيل الدخول (GET)
        // ==========================================
        [HttpGet]
        [AllowAnonymous]
        [ResponseCache(Location = ResponseCacheLocation.None, NoStore = true)]
        public async Task<IActionResult> Login(string? returnUrl = null)
        {
            // 🛑 إصلاح حلقة التكرار (Redirect Loop):
            // بدلاً من عمل RedirectToAction لنفس الصفحة (مما يسبب Loop)، 
            // نقوم بمسح الجلسة والكوكي في الخلفية ثم نظهر الصفحة مباشرة.
            if (User.Identity.IsAuthenticated)
            {
                await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                // نمسح كوكيز الفروع لضمان بيئة نظيفة للمستخدم الجديد
                Response.Cookies.Delete("ActiveBranchId");
                
                // نوجه المستخدم لصفحة تسجيل الدخول النظيفة (بدون بيانات هوية قديمة)
                // ولكن بتمرير الـ returnUrl لكي لا يفقده
                ViewData["ReturnUrl"] = returnUrl;
                return View();
            }

            // مسح كوكيز الفروع في الحالات العادية أيضاً
            Response.Cookies.Delete("ActiveBranchId");

            // تنظيف الرابط من أي مخلفات أخطاء سابقة
            if (returnUrl != null && returnUrl.Contains("HandleError")) returnUrl = null;

            ViewData["ReturnUrl"] = returnUrl;
            return View();
        }

        // ==========================================
        // 2. معالجة عملية تسجيل الدخول (POST)
        // ==========================================
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(string? username, string? password, string? returnUrl = null)
        {
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password)) return View();

            // 🚀 الإجراء الوقائي: مسح المسافات الفارغة (Trim) لحل مشاكل الإدخال
            string cleanUsername = username.Trim();

            var user = await _context.Users
                .Include(u => u.Employee)
                .FirstOrDefaultAsync(u => u.Username == cleanUsername);

            // 1. التشخيص: هل المستخدم موجود ومطابق تماماً لحالة الأحرف؟
            if (user == null || user.Username != cleanUsername)
            {
                // ❗️ تسجيل محاولة دخول فاشلة في السجلات
                await RecordLoginFailureAsync(username, "username_not_found_or_case_mismatch");
                ViewBag.Error = "اسم المستخدم أو كلمة المرور غير صحيحة.";
                return View();
            }

            // 2. التشخيص: هل الحساب نشط؟
            // نتعامل مع null كأنه نشط إلا إذا تم إيقافه صراحة 
            if (user.IsActive == false)
            {
                // ❗️ تسجيل محاولة دخول لحساب موقوف
                await RecordLoginFailureAsync(username, "account_disabled");
                ViewBag.Error = "هذا الحساب معطل حالياً، يرجى مراجعة الإدارة.";
                return View();
            }

            // 🚀 محرك الهجرة المطور (Robust Migration Engine):
            // نقوم بالتحقق من النص الصريح مع تجاهل حالة الأحرف والمسافات الزائدة
            string dbPlaintext = user.PasswordHash.Trim();
            string inputPlaintext = password.Trim();
            
            bool isLegacyMatch = !string.IsNullOrEmpty(dbPlaintext) && 
                                 string.Equals(dbPlaintext, inputPlaintext, StringComparison.OrdinalIgnoreCase);

            if (isLegacyMatch)
            {
                // ✅ ترقية فورية وآمنة لكلمة المرور
                user.PasswordHash = _passwordHasher.HashPassword(user, inputPlaintext);
                _context.Users.Update(user);
                await _context.SaveChangesAsync();
            }
            else
            {
                // 🔒 التحقق باستخدام خوارزمية التشفير الحديثة
                try 
                {
                    var result = _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, password);
                    if (result != PasswordVerificationResult.Success && result != PasswordVerificationResult.SuccessRehashNeeded)
                    {
                        // ❗️ تسجيل محاولة دخول بكلمة مرور خاطئة
                        await RecordLoginFailureAsync(username, "password_mismatch");
                        ViewBag.Error = "اسم المستخدم أو كلمة المرور غير صحيحة.";
                        return View();
                    }
                    
                    if (result == PasswordVerificationResult.SuccessRehashNeeded)
                    {
                        user.PasswordHash = _passwordHasher.HashPassword(user, password);
                        _context.Users.Update(user);
                        await _context.SaveChangesAsync();
                    }
                }
                catch
                {
                    // في حالة وجود نص قديم لا يتوافق مع صيغة الـ Hash ولم ينجح الـ Legacy Match
                    await RecordLoginFailureAsync(username, "password_mismatch_legacy");
                    ViewBag.Error = "اسم المستخدم أو كلمة المرور غير صحيحة.";
                    return View();
                }
            }

            // 2. جلب اسم الدور واسم الفرع بشكل آمن ومنفصل لضمان استقرار الربط
            string roleName = "User";
            if (user.RoleId > 0)
            {
                var role = await _context.Userroles.AsNoTracking().FirstOrDefaultAsync(r => r.RoleId == user.RoleId);
                roleName = role?.RoleArabicName ?? role?.RoleName ?? "User";
            }

            string branchName = "فرع غير محدد";
            if (user.DefaultBranchId > 0)
            {
                var branch = await _context.Branches.AsNoTracking().FirstOrDefaultAsync(b => b.BranchId == user.DefaultBranchId);
                branchName = branch?.BranchName ?? "فرع غير محدد";
            }

            // 3. بناء الهوية البرمجية (Claims) - فقط البيانات الأساسية لتجنب تضخم الكوكي
            string userFullName = user.Employee?.FullName ?? user.Username;

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name, user.Username),
                new Claim("FullName", userFullName),
                new Claim("UserID", user.UserId.ToString()),
                new Claim("RoleID", user.RoleId.ToString()),
                new Claim(ClaimTypes.Role, roleName),
                
                // 🚀 تأسيس العزل: الفرع الافتراضي للموظف، ونقطة البداية للمدير
                new Claim("BranchID", user.DefaultBranchId?.ToString() ?? "1"),
                new Claim("BranchName", branchName)
            };

            // 🚀 إضافة الهوية الصريحة لمدير النظام لتفادي اختفائها في الواجهات (User.IsInRole)
            if (user.RoleId == 1)
            {
                claims.Add(new Claim(ClaimTypes.Role, "SuperAdmin"));
            }

            // تم إزالة حلقة (foreach) الخاصة بـ Permissions من هنا لتخفيف حجم الـ Cookie وحل خطأ ERR_HTTP2_PROTOCOL_ERROR
            // سيتولى كلاس (ClaimsTransformer) جلب الصلاحيات ديناميكياً في الذاكرة لاحقاً

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

            var authProperties = new AuthenticationProperties
            {
                IsPersistent = true, // تذكرني
                ExpiresUtc = DateTimeOffset.UtcNow.AddHours(12) // صلاحية الجلسة
            };

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(claimsIdentity),
                authProperties);

            // 🛡️ توثيق عملية الدخول في سجلات الرقابة (عبر الموتور المورث من BaseController)
            // نمرر ActiveBranchId الافتراضي الذي تم تأسيسه للتو
            await RecordLog("Login", "Account", $"المستخدم {user.Username} سجل دخوله بنجاح من {branchName}.");

            // التوجيه الذكي
            if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl) && !returnUrl.Contains("HandleError"))
            {
                return Redirect(returnUrl);
            }

            return RedirectToAction("Index", "Home");
        }

        // ==========================================
        // 3. دالة تسجيل الخروج 
        // ==========================================
        [HttpGet]
        [ResponseCache(Location = ResponseCacheLocation.None, NoStore = true)]
        public async Task<IActionResult> Logout()
        {
            if (User.Identity.IsAuthenticated)
            {
                await RecordLog("Logout", "Account", "قام المستخدم بتسجيل الخروج بنجاح.");
            }

            // 🚀 العزل الأمني: تدمير كوكي "الفرع النشط" لكي لا يرثه من يستخدم الجهاز لاحقاً
            Response.Cookies.Delete("ActiveBranchId");

            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Login", "Account");
        }

        // ==========================================
        // 4. تغيير كلمة المرور
        // ==========================================
        [Authorize]
        [HttpGet]
        public IActionResult ChangePassword() => View();

        [Authorize]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ChangePassword(string? currentPassword, string? newPassword, string? confirmPassword)
        {
            if (string.IsNullOrEmpty(currentPassword) || string.IsNullOrEmpty(newPassword) || string.IsNullOrEmpty(confirmPassword)) return View();

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == User.Identity.Name);
            if (user == null)
            {
                ViewBag.Error = "تعذر تحميل بيانات المستخدم.";
                return View();
            }

            bool currentValid =
                user.PasswordHash == currentPassword
                || _passwordHasher.VerifyHashedPassword(user, user.PasswordHash, currentPassword) is PasswordVerificationResult.Success or PasswordVerificationResult.SuccessRehashNeeded;

            if (!currentValid)
            {
                ViewBag.Error = "كلمة المرور الحالية غير صحيحة!";
                return View();
            }

            if (newPassword != confirmPassword)
            {
                ViewBag.Error = "كلمة المرور الجديدة غير متطابقة!";
                return View();
            }

            user.PasswordHash = _passwordHasher.HashPassword(user, newPassword);
            _context.Update(user);
            await _context.SaveChangesAsync();

            await RecordLog("Update", "Account", "تم تغيير كلمة المرور بنجاح.");
            return RedirectToAction("Index", "Home");
        }
        // ==========================================
        // ️⃣ دالة مساعدة خاصة بتسجيل فشل الدخول
        // (AccountController لا يرث RecordLog العادي لأنه غير مصادق عليه بعد)
        // ==========================================
        private async Task RecordLoginFailureAsync(string attemptedUsername, string reason)
        {
            try
            {
                var reasonText = reason switch
                {
                    "username_not_found" => "اسم مستخدم غير موجود",
                    "account_disabled"   => "حساب معطل",
                    "password_mismatch"  => "كلمة مرور خاطئة",
                    _                    => "غير معروف"
                };

                var log = new SystemLogs
                {
                    UserId     = 0, // 0 = محاولة غير مصادق عليه
                    Action     = "LoginFailed",
                    ScreenName = "Account",
                    Details    = $"محاولة دخول فاشلة - اسم المستخدم: [{attemptedUsername}] - السبب: {reasonText}",
                    IPAddress  = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Unknown",
                    CreatedAt  = DateTime.Now
                };
                _context.Systemlogs.Add(log);
                await _context.SaveChangesAsync();
            }
            catch { }
        }
        // ==========================================
        // 5. استعادة كلمة المرور (Forgot Password)
        // ==========================================
        [HttpGet]
        [AllowAnonymous]
        public IActionResult ForgotPassword() => View();

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ForgotPassword(string username)
        {
            if (string.IsNullOrEmpty(username)) return View();

            var user = await _context.Users
                .Include(u => u.Employee)
                .FirstOrDefaultAsync(u => u.Username == username.Trim());

            if (user == null || user.IsActive == false || user.Employee == null || string.IsNullOrEmpty(user.Employee.Phone))
            {
                ViewBag.Error = "تعذر إرسال الرمز. تأكد من صحة اسم المستخدم وأن حسابك مرتبط بموظف لديه رقم هاتف مسجل.";
                return View();
            }

            // توليد رمز OTP
            string otp = new Random().Next(100000, 999999).ToString();
            
            // حفظ في الكاش لمدة 10 دقائق
            _cache.Set($"OTP_{user.Username}", otp, TimeSpan.FromMinutes(10));

            // محاولة إرسال عبر الواتساب
            var instanceId = _configuration["WhatsApp:InstanceId"];
            var token      = _configuration["WhatsApp:Token"];
            bool whatsAppConfigured = !string.IsNullOrEmpty(instanceId) && !string.IsNullOrEmpty(token);

            if (whatsAppConfigured)
            {
                string msg = $"مرحباً {user.Employee.FullName}،\nرمز استعادة كلمة المرور الخاص بك في نظام PharmaSmart هو: *{otp}*\n(الرمز صالح لمدة 10 دقائق).";
                await _whatsappService.SendMessageAsync(user.Employee.Phone, msg);
            }
            else
            {
                // وضع الاختبار: عرض الرمز مباشرة على الشاشة (يُستخدم عند غياب إعدادات الواتساب)
                TempData["DevOtp"] = otp;
            }

            TempData["ResetUsername"] = user.Username;
            return RedirectToAction(nameof(VerifyOTP));
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult VerifyOTP()
        {
            if (TempData["ResetUsername"] == null) return RedirectToAction(nameof(Login));
            ViewBag.Username = TempData.Peek("ResetUsername");
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public IActionResult VerifyOTP(string otpCode)
        {
            string? username = TempData.Peek("ResetUsername")?.ToString();
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(otpCode)) return RedirectToAction(nameof(Login));

            if (_cache.TryGetValue($"OTP_{username}", out string? savedOtp))
            {
                if (savedOtp == otpCode.Trim())
                {
                    TempData["OTPVerified"] = true;
                    TempData.Keep("ResetUsername");
                    return RedirectToAction(nameof(ResetPassword));
                }
            }

            ViewBag.Error = "الرمز المدخل غير صحيح أو انتهت صلاحيته.";
            ViewBag.Username = username;
            return View();
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult ResetPassword()
        {
            if (TempData.Peek("ResetUsername") == null || TempData.Peek("OTPVerified") == null) 
                return RedirectToAction(nameof(Login));
            
            ViewBag.Username = TempData.Peek("ResetUsername");
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ResetPassword(string newPassword, string confirmPassword)
        {
            string? username = TempData["ResetUsername"]?.ToString();
            if (string.IsNullOrEmpty(username)) return RedirectToAction(nameof(Login));

            if (string.IsNullOrEmpty(newPassword) || newPassword != confirmPassword)
            {
                TempData.Keep("ResetUsername");
                TempData.Keep("OTPVerified");
                ViewBag.Error = "كلمة المرور غير متطابقة أو فارغة.";
                ViewBag.Username = username;
                return View();
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
            if (user != null)
            {
                user.PasswordHash = _passwordHasher.HashPassword(user, newPassword);
                _context.Users.Update(user);
                await _context.SaveChangesAsync();
                
                // مسح الـ OTP من الكاش
                _cache.Remove($"OTP_{username}");
                
                TempData["SuccessMessage"] = "تم إعادة تعيين كلمة المرور بنجاح. يمكنك الآن تسجيل الدخول.";
            }

            return RedirectToAction(nameof(Login));
        }
    }
}