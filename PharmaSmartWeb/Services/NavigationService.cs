using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace PharmaSmartWeb.Services
{
    // ==========================================
    // 🌍 محتويات القائمة (Navigation Models)
    // ==========================================
    
    public class MenuItem
    {
        public string Title { get; set; }
        public string Url { get; set; }
        public string Icon { get; set; }
        public string RequiredPolicy { get; set; }
    }

    public class MenuGroup
    {
        public string Title { get; set; }
        public string Icon { get; set; }
        public List<MenuItem> Items { get; set; } = new List<MenuItem>();
    }

    // ==========================================
    // 🧠 واجهة المحرك الديناميكي (Engine Interface)
    // ==========================================
    public interface INavigationService
    {
        Task<List<MenuGroup>> GetAllowedMenusAsync(ClaimsPrincipal user);
    }

    // ==========================================
    // ⚙️ تطبيق المحرك (Engine Implementation)
    // ==========================================
    public class NavigationService : INavigationService
    {
        private readonly IAuthorizationService _authorizationService;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public NavigationService(IAuthorizationService authorizationService, IHttpContextAccessor httpContextAccessor)
        {
            _authorizationService = authorizationService;
            _httpContextAccessor = httpContextAccessor;
        }

        // ✅ إصلاح: اسم الـ Claim المخزون هو "RoleID" بحرف D كبير وليس "RoleId"
        private bool IsSuperAdmin(ClaimsPrincipal user) =>
            user.IsInRole("SuperAdmin") || user.HasClaim("RoleID", "1") || user.HasClaim("RoleId", "1");

        private bool IsBranchManager(ClaimsPrincipal user) =>
            user.IsInRole("BranchManager") || user.HasClaim("RoleID", "2") || user.HasClaim("RoleId", "2");

        // ✅ هل لدى المستخدم استثناءات فردية مخصصة؟
        // إذا كان لديه Claims بادئتها "UserPerm_" فهذا يعني أن له استثناءات فردية
        private bool HasUserLevelOverride(ClaimsPrincipal user) =>
            user.HasClaim(c => c.Type == "HasUserPermissionOverride" && c.Value == "true");

        // ✅ التحقق الذكي من صلاحية الشاشة:
        // - إذا لم يكن له استثناءات فردية → يتبع قواعد الدور (الطريقة العادية)
        // - إذا كان له استثناءات فردية → يتحقق من الـ Claims الفردية فقط (يتجاهل دوره)
        private bool CanView(ClaimsPrincipal user, bool roleCondition, string permClaim)
        {
            if (IsSuperAdmin(user)) return true;

            // إذا لديه استثناءات فردية → يتبعها بالكامل (لا ينظر للدور)
            if (HasUserLevelOverride(user))
                return user.HasClaim("Permission", permClaim);

            // لا استثناءات فردية → يتبع منطق الدور العادي
            return roleCondition || user.HasClaim("Permission", permClaim);
        }

        public Task<List<MenuGroup>> GetAllowedMenusAsync(ClaimsPrincipal user)
        {
            var allowedGroups = new List<MenuGroup>();

            bool superAdmin = IsSuperAdmin(user);
            bool branchManager = IsBranchManager(user);
            bool hasOverride = HasUserLevelOverride(user);

            // 1. العمليات التجارية (Commercial Operations)
            {
                var group = new MenuGroup { Title = "العمليات التجارية", Icon = "storefront", Items = new List<MenuItem>() };

                if (CanView(user, branchManager || user.IsInRole("Cashier") || user.IsInRole("Pharmacist"), "Sales.Create"))
                    group.Items.Add(new MenuItem { Title = "نقطة البيع السريعة (POS)", Url = "/Sales/Create", Icon = "point_of_sale" });

                if (CanView(user, branchManager, "Sales.View"))
                    group.Items.Add(new MenuItem { Title = "وحدة المتاجرة", Url = "/Home/CommercialHub", Icon = "dashboard" });

                if (CanView(user, branchManager, "Sales.View"))
                    group.Items.Add(new MenuItem { Title = "سجل المبيعات", Url = "/Sales/Index", Icon = "receipt_long" });

                if (CanView(user, branchManager, "SalesReturn.View"))
                    group.Items.Add(new MenuItem { Title = "مرتجع المبيعات", Url = "/SalesReturn/Index", Icon = "assignment_return" });

                if (CanView(user, branchManager || user.IsInRole("Storekeeper"), "Purchases.View"))
                    group.Items.Add(new MenuItem { Title = "سجل المشتريات", Url = "/Purchases/Index", Icon = "shopping_cart_checkout" });

                if (CanView(user, branchManager, "PurchasesReturn.View"))
                    group.Items.Add(new MenuItem { Title = "مرتجع المشتريات", Url = "/PurchasesReturn/Index", Icon = "remove_shopping_cart" });

                if (group.Items.Any()) allowedGroups.Add(group);
            }

            // 2. المخزون والإمداد (Inventory & Supply)
            {
                var group = new MenuGroup { Title = "المخزون والإمداد", Icon = "inventory_2", Items = new List<MenuItem>() };

                group.Items.Add(new MenuItem { Title = "لوحة تحكم المخزون", Url = "/Home/InventoryHub", Icon = "dashboard" });

                if (CanView(user, branchManager || user.IsInRole("Pharmacist") || user.IsInRole("Storekeeper"), "Drug.View"))
                    group.Items.Add(new MenuItem { Title = "الأدوية والمخزون", Url = "/Drugs/Index", Icon = "medication" });

                if (superAdmin || branchManager || user.IsInRole("Storekeeper") || user.IsInRole("Pharmacist"))
                {
                    group.Items.Add(new MenuItem { Title = "المجموعات العلاجية", Url = "/ItemGroups/Index", Icon = "category" });
                    group.Items.Add(new MenuItem { Title = "تسعير الأدوية (WAC)", Url = "/Pricing/Index", Icon = "price_change" });
                    group.Items.Add(new MenuItem { Title = "المستودعات والرفوف", Url = "/Warehouses/Index", Icon = "warehouse" });
                    group.Items.Add(new MenuItem { Title = "جرد وتسوية المخزون", Url = "/StockAudit/Index", Icon = "rule" });
                    group.Items.Add(new MenuItem { Title = "التحويلات المخزنية", Url = "/DrugTransfers/Index", Icon = "local_shipping" });
                    group.Items.Add(new MenuItem { Title = "طباعة الباركود", Url = "/Barcode/Index", Icon = "barcode_scanner" });
                }

                if (superAdmin || branchManager || user.HasClaim("Permission", "System.ChangeBranch"))
                {
                    group.Items.Add(new MenuItem { Title = "نواقص الأدوية", Url = "/Inventory/Shortages", Icon = "warning_amber" });
                    group.Items.Add(new MenuItem { Title = "مراقبة الصلاحية", Url = "/Report/StockExpiry", Icon = "event_busy" });
                }

                if (group.Items.Any()) allowedGroups.Add(group);
            }

            // 3. المالية والحسابات (Finance & Accounts)
            {
                var group = new MenuGroup { Title = "المالية والحسابات", Icon = "account_balance", Items = new List<MenuItem>() };

                if (CanView(user, branchManager || user.IsInRole("Accountant"), "Accounts.View"))
                {
                    group.Items.Add(new MenuItem { Title = "لوحة تحكم المالية", Url = "/Home/FinanceHub", Icon = "account_balance" });
                    group.Items.Add(new MenuItem { Title = "الدليل المحاسبي", Url = "/Accounting/Index", Icon = "account_tree" });
                    group.Items.Add(new MenuItem { Title = "القيود اليومية", Url = "/JournalEntries/Index", Icon = "history_edu" });
                    group.Items.Add(new MenuItem { Title = "سندات القبض والصرف", Url = "/Vouchers/Index", Icon = "payments" });
                    group.Items.Add(new MenuItem { Title = "التحويلات المالية", Url = "/FundTransfers/Index", Icon = "currency_exchange" });
                }

                if (superAdmin || branchManager || user.IsInRole("Accountant"))
                {
                    group.Items.Add(new MenuItem { Title = "كشف الحساب", Url = "/Report/Ledger", Icon = "list_alt" });
                }

                if (group.Items.Any()) allowedGroups.Add(group);
            }

            // 4. العلاقات التجارية (Commercial Relations)
            {
                var group = new MenuGroup { Title = "العلاقات التجارية", Icon = "groups", Items = new List<MenuItem>() };

                if (superAdmin || branchManager || user.IsInRole("Accountant"))
                {
                    group.Items.Add(new MenuItem { Title = "إدارة العملاء", Url = "/Customers/Index", Icon = "person_add" });
                    group.Items.Add(new MenuItem { Title = "إدارة الموردين", Url = "/Suppliers/Index", Icon = "local_shipping" });
                    group.Items.Add(new MenuItem { Title = "سجل الموظفين", Url = "/Employees/Index", Icon = "badge" });
                }

                if (group.Items.Any()) allowedGroups.Add(group);
            }

            // 5. التخطيط والتنبؤ (Planning & Forecasting)
            {
                var group = new MenuGroup { Title = "التخطيط والتنبؤ", Icon = "auto_graph", Items = new List<MenuItem>() };

                if (superAdmin || branchManager || user.IsInRole("Accountant") || user.HasClaim("Permission", "System.ChangeBranch"))
                {
                    group.Items.Add(new MenuItem { Title = "مركز التخطيط والتنبؤ", Url = "/InventoryIntelligence/PlanningHub", Icon = "auto_graph" });
                }

                if (group.Items.Any()) allowedGroups.Add(group);
            }

            // 6. التقارير المركزية (Reports Center)
            {
                var group = new MenuGroup { Title = "التقارير المركزية", Icon = "donut_large", Items = new List<MenuItem>() };

                if (superAdmin || branchManager || user.HasClaim("Permission", "System.ChangeBranch"))
                {
                    group.Items.Add(new MenuItem { Title = "مركز التقارير (اللوحة الرئيسية)", Url = "/Home/ReportsHub", Icon = "dashboard" });
                    
                    // تحليلات مالية
                    group.Items.Add(new MenuItem { Title = "قائمة الدخل والأرباح", Url = "/Report/IncomeStatement", Icon = "point_of_sale" });
                    group.Items.Add(new MenuItem { Title = "ميزان المراجعة المالي", Url = "/Report/TrialBalance", Icon = "balance" });
                    group.Items.Add(new MenuItem { Title = "كشف الحساب التفصيلي", Url = "/Report/Ledger", Icon = "menu_book" });
                    group.Items.Add(new MenuItem { Title = "حركة السيولة النقدية", Url = "/Report/DailyCashFlow", Icon = "payments" });
                    
                    // أداء ومخزون
                    group.Items.Add(new MenuItem { Title = "انتاجية الفروع", Url = "/Report/PharmacistSales", Icon = "local_pharmacy" });
                    group.Items.Add(new MenuItem { Title = "مراقبة الصلاحية والاستهلاك", Url = "/Report/StockExpiry", Icon = "event_busy" });
                }

                if (group.Items.Any()) allowedGroups.Add(group);
            }

            // 7. الإدارة المركزية (Central Management)
            {
                var group = new MenuGroup { Title = "الإدارة المركزية", Icon = "admin_panel_settings", Items = new List<MenuItem>() };

                if (superAdmin)
                {
                    group.Items.Add(new MenuItem { Title = "إعدادات النظام العامة", Url = "/Admin/Index", Icon = "settings" });
                    group.Items.Add(new MenuItem { Title = "الإعدادات المالية", Url = "/FinancialSettings/Index", Icon = "settings_suggest" });
                    group.Items.Add(new MenuItem { Title = "إدارة الفروع", Url = "/Branches/Index", Icon = "account_tree" });
                    group.Items.Add(new MenuItem { Title = "إدارة المستخدمين", Url = "/Users/Index", Icon = "manage_accounts" });
                    group.Items.Add(new MenuItem { Title = "مصفوفة الصلاحيات", Url = "/Roles/Index", Icon = "admin_panel_settings" });
                    group.Items.Add(new MenuItem { Title = "إدارة العملات", Url = "/Currencies/Index", Icon = "paid" });
                    group.Items.Add(new MenuItem { Title = "النسخ الاحتياطي", Url = "/Admin/Backup", Icon = "backup" });
                    group.Items.Add(new MenuItem { Title = "سجلات الرقابة (Audit)", Url = "/Admin/SystemLogs", Icon = "policy" });
                }

                if (group.Items.Any()) allowedGroups.Add(group);
            }

            return Task.FromResult(allowedGroups);
        }

        private string DetermineActiveUnit(string controller, string action)
        {
            return "All";
        }
    }
}
