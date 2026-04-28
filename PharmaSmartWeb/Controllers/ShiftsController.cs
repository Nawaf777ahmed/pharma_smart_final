using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PharmaSmartWeb.Models;
using PharmaSmartWeb.Filters;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace PharmaSmartWeb.Controllers
{
    [Authorize]
    public class ShiftsController : BaseController
    {
        public ShiftsController(ApplicationDbContext context) : base(context)
        {
        }

        private async Task<int> GetValidUserIdAsync()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value ?? User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(userIdClaim) && int.TryParse(userIdClaim, out int parsedId))
            {
                if (await _context.Users.AnyAsync(u => u.UserId == parsedId)) return parsedId;
            }
            throw new Exception("انتهت صلاحية الجلسة أو تعذر التحقق من هوية المستخدم. يرجى تسجيل الدخول مجدداً.");
        }

        [HttpGet]
        [HasPermission("Sales", "Add")]
        public async Task<IActionResult> OpenShift()
        {
            var userId = await GetValidUserIdAsync();

            // تحقق إذا كان لديه وردية مفتوحة مسبقاً
            var openShift = await _context.Shifts
                .FirstOrDefaultAsync(s => s.UserId == userId && s.BranchId == ActiveBranchId && s.Status == "Open");

            if (openShift != null)
            {
                TempData["Info"] = "لديك وردية مفتوحة بالفعل.";
                return RedirectToAction("Create", "Sales");
            }

            return View(new Shifts { OpeningBalance = 0 });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [HasPermission("Sales", "Add")]
        public async Task<IActionResult> OpenShift(Shifts shift)
        {
            var userId = await GetValidUserIdAsync();

            var openShift = await _context.Shifts
                .FirstOrDefaultAsync(s => s.UserId == userId && s.BranchId == ActiveBranchId && s.Status == "Open");

            if (openShift != null)
            {
                TempData["Error"] = "لديك وردية مفتوحة بالفعل. لا يمكنك فتح وردية جديدة.";
                return RedirectToAction("Create", "Sales");
            }

            shift.UserId = userId;
            shift.BranchId = ActiveBranchId;
            shift.OpenedAt = DateTime.Now;
            shift.Status = "Open";
            shift.ExpectedCash = shift.OpeningBalance; // الإجمالي المبدئي

            _context.Shifts.Add(shift);
            await _context.SaveChangesAsync();

            await RecordLog("OpenShift", "Shifts", $"تم فتح وردية جديدة للرقم {shift.ShiftId} بعهدة مبدئية {shift.OpeningBalance}");

            TempData["Success"] = "تم فتح الوردية بنجاح.";
            return RedirectToAction("Create", "Sales");
        }

        [HttpGet]
        [HasPermission("Sales", "Add")]
        public async Task<IActionResult> Close()
        {
            var userId = await GetValidUserIdAsync();

            var openShift = await _context.Shifts
                .Include(s => s.Sales)
                    .ThenInclude(sale => sale.SalePayments)
                .FirstOrDefaultAsync(s => s.UserId == userId && s.BranchId == ActiveBranchId && s.Status == "Open");

            if (openShift == null)
            {
                TempData["Error"] = "ليس لديك وردية مفتوحة للإغلاق.";
                return RedirectToAction("Index", "Sales");
            }

            var normalSales = openShift.Sales.Where(s => !s.IsReturn).ToList();
            var returns = openShift.Sales.Where(s => s.IsReturn).ToList();

            decimal totalCashSales = normalSales.SelectMany(s => s.SalePayments).Where(p => p.PaymentMethod == "Cash").Sum(p => p.Amount);
            decimal totalCashReturns = returns.SelectMany(s => s.SalePayments).Where(p => p.PaymentMethod == "Cash").Sum(p => p.Amount);

            // النقد المتوقع = العهدة المبدئية + المبيعات النقدية - المرتجعات النقدية
            openShift.ExpectedCash = openShift.OpeningBalance + totalCashSales - totalCashReturns;

            ViewBag.TotalSales = normalSales.Sum(s => s.NetAmount);
            ViewBag.TotalReturns = returns.Sum(s => s.NetAmount);
            ViewBag.TotalCash = totalCashSales;
            ViewBag.TotalBank = normalSales.SelectMany(s => s.SalePayments).Where(p => p.PaymentMethod == "Bank").Sum(p => p.Amount);
            
            return View(openShift);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [HasPermission("Sales", "Add")]
        public async Task<IActionResult> ConfirmClose(int ShiftId, decimal ActualCash)
        {
            var userId = await GetValidUserIdAsync();

            var openShift = await _context.Shifts
                .FirstOrDefaultAsync(s => s.ShiftId == ShiftId && s.UserId == userId && s.BranchId == ActiveBranchId && s.Status == "Open");

            if (openShift == null)
            {
                TempData["Error"] = "الوردية غير موجودة أو تم إغلاقها مسبقاً.";
                return RedirectToAction("Index", "Sales");
            }

            openShift.ActualCash = ActualCash;
            openShift.Difference = ActualCash - openShift.ExpectedCash;
            openShift.ClosedAt = DateTime.Now;
            openShift.Status = "Closed";

            _context.Shifts.Update(openShift);
            
            // TODO: ترحيل الفروقات والعهد إلى النظام المحاسبي (إنشاء قيد يومية)

            await _context.SaveChangesAsync();

            await RecordLog("CloseShift", "Shifts", $"تم إغلاق الوردية رقم {openShift.ShiftId}. الفعلي: {ActualCash}, الفرق: {openShift.Difference}");

            TempData["Success"] = "تم إغلاق الوردية وتصفير العدادات بنجاح.";
            return RedirectToAction("Index", "Sales");
        }
    }
}
