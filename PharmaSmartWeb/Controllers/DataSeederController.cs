using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PharmaSmartWeb.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace PharmaSmartWeb.Controllers
{
    [Route("DataSeeder/[action]")]
    public class DataSeederController : BaseController
    {
        public DataSeederController(ApplicationDbContext context) : base(context) { }

        [HttpGet]
        public IActionResult Index() => View();

        [HttpPost]
        public async Task<IActionResult> SeedAllData()
        {
            _context.Database.SetCommandTimeout(3600); 
            try
            {
                int userId = 1;
                int branchId = ActiveBranchId;

                string filePath = Path.Combine(Directory.GetCurrentDirectory(), "..", "drugs_list.txt");
                string[] drugNames;
                if (!System.IO.File.Exists(filePath))
                {
                    drugNames = new[] { "بانادول 500مج", "أوجمنتين 1جم", "بروفين 400مج", "فيتامين سي 1000", "كونجستال", "أدول", "اموكسيل 500", "ريفو 320مج", "كاتافلام 50مج", "سيبتازول" };
                }
                else 
                {
                    drugNames = (await System.IO.File.ReadAllLinesAsync(filePath))
                        .Where(n => !string.IsNullOrWhiteSpace(n)).Distinct().Take(200).ToArray();
                }

                // Ensure essential accounts
                var cashAcc    = await _context.Accounts.FirstOrDefaultAsync(a => a.BranchId == branchId && a.AccountName.Contains("صندوق") && !a.IsParent);
                var salesAcc   = await _context.Accounts.FirstOrDefaultAsync(a => a.AccountName.Contains("مبيعات") && a.BranchId == branchId);
                var capitalAcc = await _context.Accounts.FirstOrDefaultAsync(a => a.AccountName.Contains("رأس المال") || a.AccountCode.StartsWith("3"));
                var invAcc     = await _context.Accounts.FirstOrDefaultAsync(a => a.AccountName.Contains("مخزون") && a.BranchId == branchId);
                var cogsAcc    = await _context.Accounts.FirstOrDefaultAsync(a => a.AccountName.Contains("تكلفة") && a.BranchId == branchId);
                var bankAcc    = await EnsureAccount(branchId, "البنك الأهلي", "Assets", true, cashAcc?.ParentAccountId);
                var expenseAcc = await EnsureAccount(branchId, "مصروفات عامة", "Expenses", true, null);

                if (cashAcc == null)  return Json(new { success = false, message = "لا يوجد حساب صندوق للفرع. يرجى إنشاء شجرة الحسابات أولاً." });
                if (salesAcc == null) return Json(new { success = false, message = "لا يوجد حساب مبيعات للفرع. يرجى إنشاء شجرة الحسابات أولاً." });
                if (capitalAcc == null) return Json(new { success = false, message = "لا يوجد حساب رأس المال. يرجى إنشاء شجرة الحسابات أولاً." });

                var supplier  = await EnsureSupplier(branchId);
                var customers = await EnsureCustomers(branchId, cashAcc.AccountId);
                var drugs     = await EnsureDrugs(drugNames, branchId);
                
                var warehouseBranch = await EnsureSecondaryBranch();
                var warehouse = await EnsureWarehouse(branchId);
                var employee = await EnsureEmployee(branchId);

                await EnsureOpeningBalance(branchId, userId, cashAcc.AccountId, capitalAcc.AccountId, bankAcc.AccountId);
                await EnsureInitialPurchases(drugs, supplier, branchId, userId);

                await SimulateIntensiveOperations(drugs, customers, branchId, userId,
                    cashAcc.AccountId, salesAcc.AccountId,
                    invAcc?.AccountId, cogsAcc?.AccountId,
                    bankAcc.AccountId, expenseAcc.AccountId,
                    warehouseBranch.BranchId);

                return Json(new { success = true, message = $"اكتملت العملية بنجاح! تم تعبئة جميع أجزاء النظام بدون استثناء بآلاف العمليات المتكاملة." });
            }
            catch (Exception ex)
            {
                var inner = ex.InnerException?.Message ?? ex.Message;
                return Json(new { success = false, message = "حدث خطأ أثناء معالجة البيانات: " + inner });
            }
        }

        [HttpGet]
        public async Task<IActionResult> FixAdminPermissions()
        {
            try
            {
                // 1. العثور على صلاحية الإدمن (عادة رقم 1 أو باسم Admin)
                var adminRole = await _context.Userroles.FirstOrDefaultAsync(r => r.RoleId == 1 || r.RoleName == "Admin");
                if (adminRole == null)
                {
                    return Json(new { success = false, message = "لم يتم العثور على صلاحية مدير النظام (Admin)" });
                }

                // 2. جلب جميع الشاشات في النظام
                var screens = await _context.Systemscreens.ToListAsync();

                int addedCount = 0;
                int updatedCount = 0;

                foreach (var screen in screens)
                {
                    var existingPerm = await _context.Screenpermissions
                        .FirstOrDefaultAsync(p => p.RoleId == adminRole.RoleId && p.ScreenId == screen.ScreenId);

                    if (existingPerm != null)
                    {
                        existingPerm.CanView = true;
                        existingPerm.CanAdd = true;
                        existingPerm.CanEdit = true;
                        existingPerm.CanDelete = true;
                        existingPerm.CanPrint = true;
                        updatedCount++;
                    }
                    else
                    {
                        _context.Screenpermissions.Add(new Screenpermissions
                        {
                            RoleId = adminRole.RoleId,
                            ScreenId = screen.ScreenId,
                            CanView = true,
                            CanAdd = true,
                            CanEdit = true,
                            CanDelete = true,
                            CanPrint = true
                        });
                        addedCount++;
                    }
                }

                await _context.SaveChangesAsync();
                return Json(new { success = true, message = $"تم إصلاح صلاحيات المدير (Admin). تم إضافة {addedCount} شاشة جديدة وتحديث {updatedCount} شاشة موجودة لتكون بكامل الصلاحيات." });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = "حدث خطأ أثناء إصلاح الصلاحيات: " + ex.Message });
            }
        }

        private static readonly Random _rng = new();
        private static readonly string[] FirstNames = { "محمد", "أحمد", "عبدالله", "محمود", "علي", "عمر", "خالد", "حسن", "حسين", "طارق", "يوسف", "ياسر", "مصطفى", "إبراهيم", "فارس", "سعد", "سعيد", "سلمان", "عبدالرحمن", "فهد" };
        private static readonly string[] LastNames = { "السعيد", "الغامدي", "العمري", "الشريف", "المصري", "سالم", "كمال", "الدين", "الشهري", "المالكي", "العتيبي", "القحطاني", "العنزي", "الجهني" };
        private static readonly string[] SupplierNames = { "الشركة الطبية الحديثة", "مؤسسة الشفاء للأدوية", "فارما كير جروب", "العالمية للصناعات الدوائية", "ابن سينا للتوزيع", "النهدي الطبية", "الدواء للتوزيع", "الرواد للأدوية" };

        private async Task<Accounts> EnsureAccount(int branchId, string name, string type, bool nature, int? parentId)
        {
            var acc = await _context.Accounts.FirstOrDefaultAsync(a => a.AccountName == name && a.BranchId == branchId);
            if (acc != null) return acc;

            acc = new Accounts
            {
                AccountCode = $"ACC-{branchId}-{Guid.NewGuid().ToString().Substring(0, 4)}",
                AccountName = name,
                AccountType = type,
                AccountNature = nature,
                IsParent = false,
                IsActive = true,
                ParentAccountId = parentId,
                BranchId = branchId,
                CreatedAt = DateTime.Now
            };
            _context.Accounts.Add(acc);
            await _context.SaveChangesAsync();
            return acc;
        }

        private async Task<Branches> EnsureSecondaryBranch()
        {
            string name = "فرع المستودع الرئيسي";
            var b = await _context.Branches.FirstOrDefaultAsync(x => x.BranchName == name);
            if (b != null) return b;

            b = new Branches
            {
                BranchCode = "B-WH-01",
                BranchName = name,
                Location = "المنطقة الصناعية",
                IsActive = true
            };
            _context.Branches.Add(b);
            await _context.SaveChangesAsync();
            return b;
        }

        private async Task<Warehouses> EnsureWarehouse(int branchId)
        {
            var w = await _context.Warehouses.FirstOrDefaultAsync(x => x.BranchId == branchId);
            if (w != null) return w;

            w = new Warehouses
            {
                BranchId = branchId,
                WarehouseName = "المستودع الداخلي",
                Location = "الخلفي",
                IsActive = true
            };
            _context.Warehouses.Add(w);
            await _context.SaveChangesAsync();

            var shelf = new Shelves
            {
                WarehouseId = w.WarehouseId,
                ShelfName = "الرف A1",
                IsActive = true
            };
            _context.Shelves.Add(shelf);
            await _context.SaveChangesAsync();

            return w;
        }

        private async Task<Employees> EnsureEmployee(int branchId)
        {
            var e = await _context.Employees.FirstOrDefaultAsync(x => x.BranchId == branchId);
            if (e != null) return e;

            e = new Employees
            {
                BranchId = branchId,
                FullName = "عبدالله مدير الحسابات",
                Position = "محاسب",
                Phone = "0500000000",
                Salary = 6000,
                IsActive = true
            };
            _context.Employees.Add(e);
            await _context.SaveChangesAsync();
            return e;
        }

        private async Task<Suppliers> EnsureSupplier(int branchId)
        {
            string name = "شركة الشرق الأوسط للأدوية";
            var s = await _context.Suppliers.FirstOrDefaultAsync(x => x.SupplierName == name && x.BranchId == branchId);
            if (s != null) return s;

            var parentAcc = await _context.Accounts.FirstOrDefaultAsync(a => a.AccountName.Contains("الموردين") || a.AccountCode == "211");
            var acct = await EnsureAccount(branchId, name, parentAcc?.AccountType ?? "Liabilities", false, parentAcc?.AccountId);

            s = new Suppliers 
            { 
                SupplierName = name, 
                BranchId     = branchId, 
                IsActive     = true, 
                AccountId    = acct.AccountId,
                CreatedAt    = DateTime.Now 
            };
            _context.Suppliers.Add(s);
            await _context.SaveChangesAsync();
            return s;
        }

        private async Task<List<Customers>> EnsureCustomers(int branchId, int fallbackAccountId)
        {
            var names = new[] { "عميل نقدي", "عميل آجل", "تأمين بوبا", "تأمين التعاونية" };
            var list = new List<Customers>();

            var parentAcc = await _context.Accounts.FirstOrDefaultAsync(a => a.AccountName.Contains("العملاء") || a.AccountCode == "212");

            foreach (var name in names)
            {
                var c = await _context.Customers.FirstOrDefaultAsync(x => x.FullName == name && x.BranchId == branchId);
                if (c == null)
                {
                    var acct = await EnsureAccount(branchId, name, parentAcc?.AccountType ?? "Assets", true, parentAcc?.AccountId);
                    c = new Customers
                    {
                        FullName  = name,
                        BranchId  = branchId,
                        IsActive  = true,
                        AccountId = acct.AccountId,
                        CreatedAt = DateTime.Now
                    };
                    _context.Customers.Add(c);
                    await _context.SaveChangesAsync();
                }
                list.Add(c);
            }
            return list;
        }

        private async Task<List<Drugs>> EnsureDrugs(string[] names, int branchId)
        {
            var group = await _context.ItemGroups.FirstOrDefaultAsync(g => g.GroupName == "عام")
                        ?? new ItemGroups { GroupName = "عام", IsActive = true };
            if (group.GroupId == 0) { _context.ItemGroups.Add(group); await _context.SaveChangesAsync(); }

            var list = new List<Drugs>();
            foreach (var name in names)
            {
                var d = await _context.Drugs.FirstOrDefaultAsync(x => x.DrugName == name);
                if (d == null)
                {
                    d = new Drugs
                    {
                        DrugName         = name,
                        MainUnit         = "باكت",
                        SubUnit          = "حبة",
                        ConversionFactor = 24,
                        GroupId          = group.GroupId,
                        IsActive         = true,
                        Barcode          = "460" + _rng.Next(10000, 99999).ToString() + _rng.Next(100, 999).ToString(),
                        CreatedAt        = DateTime.Now
                    };
                    _context.Drugs.Add(d);
                    await _context.SaveChangesAsync();
                }
                list.Add(d);

                if (!await _context.Branchinventory.AnyAsync(b => b.DrugId == d.DrugId && b.BranchId == branchId))
                {
                    _context.Branchinventory.Add(new Branchinventory
                    {
                        BranchId           = branchId,
                        DrugId             = d.DrugId,
                        StockQuantity      = 0,
                        MinimumStockLevel  = 10,
                        AverageCost        = 0,
                        CurrentSellingPrice = 1000
                    });
                }
            }
            await _context.SaveChangesAsync();
            return list;
        }

        private async Task EnsureOpeningBalance(int branchId, int userId, int cashId, int capitalId, int bankId)
        {
            const string desc = "رأس المال الافتتاحي";
            if (await _context.Journalentries.AnyAsync(j => j.Description == desc && j.BranchId == branchId)) return;

            _context.Journalentries.Add(new Journalentries
            {
                BranchId   = branchId,
                CreatedBy  = userId,
                IsPosted   = true,
                JournalDate = DateTime.Now.AddDays(-60),
                Description = desc,
                Journaldetails = new List<Journaldetails>
                {
                    new Journaldetails { AccountId = cashId,    Debit = 300_000, Credit = 0 },
                    new Journaldetails { AccountId = bankId,    Debit = 200_000, Credit = 0 },
                    new Journaldetails { AccountId = capitalId, Debit = 0, Credit   = 500_000 }
                }
            });
            await _context.SaveChangesAsync();
        }

        private async Task EnsureInitialPurchases(List<Drugs> drugs, Suppliers supplier, int branchId, int userId)
        {
            const string invNo = "INV-OP-01";
            if (await _context.Purchases.AnyAsync(p => p.InvoiceNumber == invNo && p.BranchId == branchId)) return;

            var purchaseDate = DateTime.Now.AddDays(-60);
            var purchase = new Purchases
            {
                BranchId      = branchId,
                UserId        = userId,
                SupplierId    = supplier.SupplierId,
                InvoiceNumber = invNo,
                PurchaseDate  = purchaseDate,
                TotalAmount   = 0,
                NetAmount     = 0,
                PaymentStatus = "Paid",
                CreatedAt     = purchaseDate
            };
            _context.Purchases.Add(purchase);
            await _context.SaveChangesAsync();

            decimal total = 0;
            foreach (var d in drugs)
            {
                int qty = _rng.Next(10, 50); // كمية افتتاحية واقعية بدلاً من 200-500
                decimal cost = _rng.Next(5, 50) * 100; // تكلفة بين 500 و 5000
                decimal price = cost * 1.3m; // هامش ربح 30%

                _context.Purchasedetails.Add(new Purchasedetails
                {
                    PurchaseId       = purchase.PurchaseId,
                    DrugId           = d.DrugId,
                    Quantity         = qty,
                    CostPrice        = cost,
                    SellingPrice     = price,
                    RemainingQuantity = qty,
                    ExpiryDate       = DateTime.Now.AddMonths(_rng.Next(6, 36)),
                    BatchNumber      = "B-" + _rng.Next(1000, 9999),
                    SubTotal         = qty * cost
                });

                var inv = await _context.Branchinventory.FirstOrDefaultAsync(b => b.BranchId == branchId && b.DrugId == d.DrugId);
                if (inv != null) { inv.StockQuantity = qty; inv.AverageCost = cost; inv.CurrentSellingPrice = price; }
                total += qty * cost;
                
                // Add Stock Movement
                _context.Stockmovements.Add(new Stockmovements {
                    BranchId = branchId, DrugId = d.DrugId, MovementDate = purchaseDate, 
                    MovementType = "Purchase", Quantity = qty, UserId = userId, Notes = "رصيد افتتاحي"
                });
            }
            purchase.TotalAmount = total;
            purchase.NetAmount   = total;
            await _context.SaveChangesAsync();
        }

        private async Task SimulateIntensiveOperations(List<Drugs> drugs, List<Customers> initialCustomers,
            int branchId, int userId,
            int cashId, int salesId, int? invId, int? cogsId,
            int bankId, int expenseId, int warehouseBranchId)
        {
            DateTime start = DateTime.Now.AddDays(-60);
            int totalDays  = 60;

            var monthlyStats = new Dictionary<string, (decimal S, decimal C)>();
            
            var invDict = await _context.Branchinventory
                .Where(b => b.BranchId == branchId)
                .ToDictionaryAsync(x => x.DrugId);

            var customers = new List<Customers>(initialCustomers);
            var suppliersList = await _context.Suppliers.Where(s => s.BranchId == branchId).ToListAsync();

            var parentCustAcc = await _context.Accounts.FirstOrDefaultAsync(a => a.AccountName.Contains("العملاء") || a.AccountCode == "212");
            var parentSuppAcc = await _context.Accounts.FirstOrDefaultAsync(a => a.AccountName.Contains("الموردين") || a.AccountCode == "211");

            // المتغيرات السابقة تم إزالتها لتجنب رسائل التحذير (unused variables)

            for (int day = 0; day < totalDays; day++)
            {
                DateTime cur = start.AddDays(day);
                string key   = $"{cur.Year}-{cur.Month}";
                if (!monthlyStats.ContainsKey(key)) monthlyStats[key] = (0, 0);

                // تقليل عدد العمليات اليومية لتكون واقعية (مثلاً 20 حركة في اليوم بدلاً من 200)
                for (int op = 0; op < 20; op++)
                {
                    DateTime opDate = cur.AddHours(_rng.Next(8, 23)).AddMinutes(_rng.Next(0, 59));
                    int r = _rng.Next(1000);

                    // 80% Sales (160/day)
                    if (r < 800) 
                    {
                        decimal sTotal = 0, cTotal = 0;
                        var details = new List<Saledetails>();
                        var selectedDrugs = drugs.OrderBy(_ => _rng.Next()).Take(_rng.Next(1, 5)).ToList();

                        foreach (var d in selectedDrugs)
                        {
                            if (!invDict.TryGetValue(d.DrugId, out var inv)) continue;

                            if (inv.StockQuantity <= 0) 
                            {
                                if (_rng.Next(100) < 5) 
                                {
                                    CreateNotification("نواقص أدوية", $"الصنف {d.DrugName} وصل للحد الأدنى أو نفد بالكامل.", "shortage", branchId, opDate);
                                    RecordLog("Inventory", "Shortage", $"نفاد مخزون الدواء {d.DrugName}", opDate);
                                }
                                continue;
                            }

                            int qty = Math.Min((int)inv.StockQuantity, _rng.Next(1, 4));
                            decimal sp   = inv.CurrentSellingPrice ?? 650;
                            decimal cp   = inv.AverageCost          ?? 400;
                            
                            inv.StockQuantity -= qty;
                            sTotal += qty * sp;
                            cTotal += qty * cp;
                            details.Add(new Saledetails { DrugId = d.DrugId, Quantity = qty, UnitPrice = sp });
                            
                            _context.Stockmovements.Add(new Stockmovements {
                                BranchId = branchId, DrugId = d.DrugId, MovementDate = opDate, 
                                MovementType = "Sale", Quantity = -qty, UserId = userId, Notes = "مبيعات نقدية"
                            });
                        }

                        if (sTotal > 0)
                        {
                            var cust = customers[_rng.Next(customers.Count)];
                            var sale = new Sales
                            {
                                BranchId    = branchId,
                                UserId      = userId,
                                Customer    = cust,
                                SaleDate    = opDate,
                                TotalAmount = sTotal,
                                NetAmount   = sTotal,
                                IsReturn    = false,
                                Saledetails = details
                            };
                            _context.Sales.Add(sale);
                            _context.SalePayments.Add(new SalePayments
                            {
                                Sale          = sale,
                                AccountId     = cashId,
                                Amount        = sTotal,
                                PaymentMethod = "Cash"
                            });

                            var cur2 = monthlyStats[key];
                            monthlyStats[key] = (cur2.S + sTotal, cur2.C + cTotal);
                        }
                    }
                    // 2% Purchases (4/day)
                    else if (r < 820)
                    {
                        var supp = suppliersList[_rng.Next(suppliersList.Count)];
                        var purchase = new Purchases
                        {
                            BranchId      = branchId,
                            UserId        = userId,
                            Supplier      = supp,
                            InvoiceNumber = $"INV-{cur:yyyyMMdd}-{Guid.NewGuid().ToString("N").Substring(0, 6)}",
                            PurchaseDate  = opDate,
                            TotalAmount   = 0,
                            NetAmount     = 0,
                            PaymentStatus = "Paid",
                            CreatedAt     = opDate
                        };
                        _context.Purchases.Add(purchase);

                        decimal pTotal = 0;
                        var selectedDrugs = drugs.OrderBy(_ => _rng.Next()).Take(_rng.Next(1, 5)).ToList();
                        foreach (var d in selectedDrugs)
                        {
                            if (!invDict.TryGetValue(d.DrugId, out var inv)) continue;
                            int qty = _rng.Next(5, 20); // شراء كميات معقولة
                            decimal cost = inv.AverageCost > 0 ? inv.AverageCost.Value : _rng.Next(5, 50) * 100;
                            
                            _context.Purchasedetails.Add(new Purchasedetails
                            {
                                Purchase         = purchase,
                                DrugId           = d.DrugId,
                                Quantity         = qty,
                                CostPrice        = cost,
                                SubTotal         = qty * cost,
                                ExpiryDate       = opDate.AddMonths(_rng.Next(6, 36)),
                                BatchNumber      = "B-" + _rng.Next(1000, 9999)
                            });

                            inv.StockQuantity += qty;
                            pTotal += qty * cost;
                            
                            _context.Stockmovements.Add(new Stockmovements {
                                BranchId = branchId, DrugId = d.DrugId, MovementDate = opDate, 
                                MovementType = "Purchase", Quantity = qty, UserId = userId, Notes = "مشتريات جديدة"
                            });
                        }
                        purchase.TotalAmount = pTotal;
                        purchase.NetAmount   = pTotal;
                    }
                    // 2% Vouchers (Expense/Receipt)
                    else if (r < 840)
                    {
                        _context.Vouchers.Add(new Vouchers {
                            BranchId = branchId,
                            VoucherType = "Payment",
                            VoucherDate = opDate,
                            Amount = _rng.Next(100, 1500),
                            FromAccountId = cashId,
                            ToAccountId = expenseId,
                            Description = "سداد مصروفات عامة ونثريات",
                            CreatedBy = userId
                        });
                    }
                    // 2% Add Customer
                    else if (r < 860)
                    {
                        string uniqueSuffix = Guid.NewGuid().ToString("N").Substring(0, 6);
                        string cName = FirstNames[_rng.Next(FirstNames.Length)] + " " + LastNames[_rng.Next(LastNames.Length)] + " - " + uniqueSuffix;
                        var acct = new Accounts
                        {
                            AccountCode   = $"C-{branchId}-{uniqueSuffix}",
                            AccountName   = cName,
                            AccountType   = parentCustAcc?.AccountType ?? "Assets",
                            AccountNature = true,
                            IsParent      = false,
                            IsActive      = true,
                            ParentAccountId = parentCustAcc?.AccountId,
                            BranchId      = branchId,
                            CreatedAt     = opDate
                        };
                        _context.Accounts.Add(acct);
                        var c = new Customers
                        {
                            FullName  = cName,
                            BranchId  = branchId,
                            IsActive  = true,
                            Account   = acct,
                            CreatedAt = opDate
                        };
                        _context.Customers.Add(c);
                        customers.Add(c);
                        
                        RecordLog("Customers", "Create", $"إضافة عميل جديد: {cName}", opDate);
                    }
                    // 1% Add Supplier
                    else if (r < 870)
                    {
                        string uniqueSuffix = Guid.NewGuid().ToString("N").Substring(0, 6);
                        string sName = SupplierNames[_rng.Next(SupplierNames.Length)] + " " + uniqueSuffix;
                        var acct = new Accounts
                        {
                            AccountCode   = $"S-{branchId}-{uniqueSuffix}",
                            AccountName   = sName,
                            AccountType   = parentSuppAcc?.AccountType ?? "Liabilities",
                            AccountNature = false,
                            IsParent      = false,
                            IsActive      = true,
                            ParentAccountId = parentSuppAcc?.AccountId,
                            BranchId      = branchId,
                            CreatedAt     = opDate
                        };
                        _context.Accounts.Add(acct);
                        var s = new Suppliers
                        {
                            SupplierName = sName,
                            BranchId     = branchId,
                            IsActive     = true,
                            Account      = acct,
                            CreatedAt    = opDate
                        };
                        _context.Suppliers.Add(s);
                        suppliersList.Add(s);
                        
                        RecordLog("Suppliers", "Create", $"إضافة مورد جديد: {sName}", opDate);
                    }
                    // 1% Fund Transfers
                    else if (r < 880)
                    {
                        _context.Fundtransfers.Add(new Fundtransfers {
                            BranchId = branchId,
                            FromAccountId = cashId,
                            ToAccountId = bankId,
                            Amount = _rng.Next(1000, 5000),
                            TransferDate = opDate,
                            Notes = "إيداع مبيعات نقدية في البنك",
                            CreatedBy = userId
                        });
                    }
                    // 1% Stock Audits
                    else if (r < 890)
                    {
                        var sa = new Stockaudits {
                            BranchId = branchId,
                            AuditDate = opDate,
                            UserId = userId,
                            Notes = "جرد دوري سريع لبعض الأصناف",
                            Status = "Completed",
                            Stockauditdetails = new List<Stockauditdetails>()
                        };
                        var d = drugs[_rng.Next(drugs.Count)];
                        if (invDict.TryGetValue(d.DrugId, out var inv)) {
                            sa.Stockauditdetails.Add(new Stockauditdetails {
                                DrugId = d.DrugId,
                                SystemQty = (int)inv.StockQuantity,
                                PhysicalQty = (int)inv.StockQuantity,
                                Difference = 0,
                                UnitCost = inv.AverageCost ?? 400
                            });
                        }
                        _context.Stockaudits.Add(sa);
                    }
                    // 1% Drug Transfers
                    else if (r < 900)
                    {
                        var dt = new Drugtransfers {
                            FromBranchId = branchId,
                            ToBranchId = warehouseBranchId,
                            TransferDate = opDate,
                            ReceiveDate = opDate.AddHours(2),
                            Status = "Completed",
                            CreatedBy = userId,
                            ReceivedBy = userId,
                            Notes = "نقل أدوية من الصيدلية إلى المستودع",
                            Drugtransferdetails = new List<Drugtransferdetails>()
                        };
                        var d = drugs[_rng.Next(drugs.Count)];
                        if (invDict.TryGetValue(d.DrugId, out var inv) && inv.StockQuantity > 5) {
                            int tQty = 5;
                            dt.Drugtransferdetails.Add(new Drugtransferdetails {
                                DrugId = d.DrugId,
                                Quantity = tQty
                            });
                            inv.StockQuantity -= tQty;
                            _context.Stockmovements.Add(new Stockmovements {
                                BranchId = branchId, DrugId = d.DrugId, MovementDate = opDate, 
                                MovementType = "TransferOut", Quantity = -tQty, UserId = userId, Notes = "نقل للمستودع"
                            });
                        }
                        _context.Drugtransfers.Add(dt);
                    }
                    // 1% Purchase Plans
                    else if (r < 910)
                    {
                        var pp = new PurchasePlan {
                            BranchId = branchId,
                            CreatedBy = userId,
                            PlanDate = opDate,
                            Status = "Approved",
                            Notes = "خطة مشتريات استباقية",
                            EstimatedTotalCost = 0,
                            PlanDetails = new List<PurchasePlanDetail>()
                        };
                        var d = drugs[_rng.Next(drugs.Count)];
                        pp.PlanDetails.Add(new PurchasePlanDetail {
                            DrugId = d.DrugId,
                            ProposedQuantity = 50,
                            ApprovedQuantity = 50,
                            UnitCostEstimate = 400,
                            TotalCost = 20000,
                            Status = "Approved"
                        });
                        pp.EstimatedTotalCost = 20000;
                        _context.PurchasePlans.Add(pp);
                    }
                    // 5% Logs
                    else if (r < 960)
                    {
                        string[] actions = { "تسجيل الدخول", "تسجيل الخروج", "طباعة تقرير", "تحديث الإعدادات", "استعراض لوحة القيادة", "تعديل فاتورة", "تصدير بيانات" };
                        string[] modules = { "Auth", "Reports", "Settings", "Home", "Sales", "Inventory" };
                        RecordLog(modules[_rng.Next(modules.Length)], actions[_rng.Next(actions.Length)], "عملية نظام تمت بنجاح وبدون أخطاء", opDate);
                    }
                    // 4% Notifications
                    else
                    {
                        string[] msgs = { "تم استلام دفعة جديدة من المورد", "تحديث صلاحيات المستخدمين في النظام", "تنبيه بقرب انتهاء صلاحية بعض الأصناف", "تم اعتماد قائمة الأسعار الجديدة بنجاح", "تم تسجيل عجز بسيط في الصندوق وتمت التسوية" };
                        string[] cats = { "info", "admin", "expiry", "info", "warning" };
                        int idx = _rng.Next(msgs.Length);
                        CreateNotification("تحديثات وإشعارات النظام", msgs[idx], cats[idx], branchId, opDate);
                    }
                }

                await _context.SaveChangesAsync();
                _context.ChangeTracker.Clear();
                
                invDict = await _context.Branchinventory.Where(b => b.BranchId == branchId).ToDictionaryAsync(x => x.DrugId);
                customers = await _context.Customers.Where(c => c.BranchId == branchId).ToListAsync();
                suppliersList = await _context.Suppliers.Where(s => s.BranchId == branchId).ToListAsync();
            }

            await GenerateMonthlyJournals(monthlyStats, cashId, salesId, invId, cogsId, branchId, userId);
        }

        private void CreateNotification(string title, string body, string cat, int branchId, DateTime date)
        {
            var n = new SystemNotification
            {
                Title      = title,
                Body       = body,
                Category   = cat,
                Severity   = cat == "shortage" ? "critical" : (cat == "warning" ? "warning" : "info"),
                Icon       = cat == "shortage" ? "trending_down" : cat == "expiry" ? "inventory_2" : (cat == "warning" ? "warning" : "info"),
                IconColor  = cat == "shortage" ? "text-red-500" : (cat == "warning" ? "text-yellow-500" : "text-blue-500"),
                BgColor    = cat == "shortage" ? "bg-red-50 border-red-100" : (cat == "warning" ? "bg-yellow-50 border-yellow-100" : "bg-blue-50 border-blue-100"),
                BadgeColor = cat == "shortage" ? "bg-red-500" : (cat == "warning" ? "bg-yellow-500" : "bg-blue-500"),
                CreatedAt  = date,
                BranchId   = branchId,
                IsRead     = false
            };
            _context.SystemNotifications.Add(n);
        }

        private void RecordLog(string screenName, string action, string details, DateTime date)
        {
            var log = new SystemLogs
            {
                UserId     = 1,
                Action     = action,
                ScreenName = screenName,
                Details    = details,
                IPAddress  = "192.168.1." + _rng.Next(2, 254).ToString(),
                CreatedAt  = date
            };
            _context.Systemlogs.Add(log);
        }

        private async Task GenerateMonthlyJournals(Dictionary<string, (decimal S, decimal C)> stats,
            int cashId, int salesId, int? invId, int? cogsId, int branchId, int userId)
        {
            foreach (var st in stats)
            {
                if (st.Value.S <= 0) continue;
                var p = st.Key.Split('-');
                int yr = int.Parse(p[0]); int mo = int.Parse(p[1]);

                int lastDay = DateTime.DaysInMonth(yr, mo);
                var entryDate = new DateTime(yr, mo, lastDay);
                
                if (yr == DateTime.Now.Year && mo == DateTime.Now.Month && DateTime.Now.Day < lastDay)
                {
                    entryDate = DateTime.Now;
                }

                var entry = new Journalentries
                {
                    BranchId    = branchId,
                    CreatedBy   = userId,
                    IsPosted    = true,
                    JournalDate = entryDate,
                    Description = $"مبيعات مجمعة – {mo}/{yr}",
                    Journaldetails = new List<Journaldetails>
                    {
                        new Journaldetails { AccountId = cashId,  Debit = st.Value.S, Credit = 0 },
                        new Journaldetails { AccountId = salesId, Debit = 0, Credit   = st.Value.S }
                    }
                };

                if (cogsId.HasValue && invId.HasValue && cogsId > 0 && invId > 0)
                {
                    entry.Journaldetails.Add(new Journaldetails { AccountId = cogsId.Value, Debit = st.Value.C, Credit = 0 });
                    entry.Journaldetails.Add(new Journaldetails { AccountId = invId.Value,  Debit = 0, Credit   = st.Value.C });
                }
                _context.Journalentries.Add(entry);
            }
            await _context.SaveChangesAsync();
        }
    }
}
