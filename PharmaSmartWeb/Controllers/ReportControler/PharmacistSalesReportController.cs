using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PharmaSmartWeb.Filters;
using PharmaSmartWeb.Models;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace PharmaSmartWeb.Controllers.ReportControler
{
    [Authorize]
    public class PharmacistSalesReportController : BaseController
    {
        public PharmacistSalesReportController(ApplicationDbContext context) : base(context) { }

        [HttpGet("/PharmacistSalesReport")]
        [HttpGet("/PharmacistSalesReport/Index")]
        [HasPermission("AccountReports", "View")]
        public async Task<IActionResult> Index(DateTime? fromDate, DateTime? toDate)
        {
            int branchId = ReportScopeId;
            var start = fromDate?.Date ?? new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            var end = toDate?.Date.AddHours(23).AddMinutes(59) ?? DateTime.Now;

            ViewBag.FromDate = start.ToString("yyyy-MM-dd");
            ViewBag.ToDate = end.ToString("yyyy-MM-dd");

            var jQuery = _context.Journaldetails
                .Include(d => d.Journal)
                .ThenInclude(j => j.Branch)
                .Include(d => d.Account)
                .Where(d => d.Journal.JournalDate >= start && d.Journal.JournalDate <= end && d.Journal.IsPosted == true)
                .AsQueryable();

            if (branchId != 0) jQuery = jQuery.Where(d => d.Journal.BranchId == branchId);

            var journalData = await jQuery.ToListAsync();

            var salesInvoices = await _context.Sales
                .Where(s => s.SaleDate >= start && s.SaleDate <= end && (branchId == 0 || s.BranchId == branchId))
                .GroupBy(s => s.BranchId)
                .Select(g => new { BranchId = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.BranchId, x => x.Count);

            var branchData = journalData
                .GroupBy(d => new { d.Journal.BranchId, d.Journal.Branch.BranchName })
                .Select(g => {
                    var totalSales = g.Where(x => x.Account.AccountCode.StartsWith("4")).Sum(x => x.Credit - x.Debit);
                    var cogs = g.Where(x => x.Account.AccountCode.StartsWith("511") || x.Account.AccountCode.StartsWith("512")).Sum(x => x.Debit - x.Credit);
                    var expenses = g.Where(x => x.Account.AccountCode.StartsWith("5") && !x.Account.AccountCode.StartsWith("511") && !x.Account.AccountCode.StartsWith("512")).Sum(x => x.Debit - x.Credit);
                    
                    return new BranchProductivityViewModel
                    {
                        BranchId = g.Key.BranchId,
                        BranchName = g.Key.BranchName ?? "غير محدد",
                        InvoiceCount = salesInvoices.ContainsKey(g.Key.BranchId) ? salesInvoices[g.Key.BranchId] : 0,
                        TotalSales = totalSales,
                        TotalExpenses = expenses,
                        COGS = cogs,
                        NetProfit = totalSales - cogs - expenses
                    };
                })
                .OrderByDescending(x => x.TotalSales)
                .ToList();

            decimal grandTotalSales = branchData.Sum(x => x.TotalSales);
            foreach (var item in branchData)
            {
                item.ContributionPercentage = grandTotalSales > 0 ? (double)(item.TotalSales / grandTotalSales * 100) : 0;
            }

            ViewBag.GrandTotalSales = grandTotalSales;
            ViewBag.TotalProfits = branchData.Sum(x => x.NetProfit);
            ViewBag.TotalExpenses = branchData.Sum(x => x.TotalExpenses);

            // Serialize for Chart.js
            ViewBag.ChartLabels = Newtonsoft.Json.JsonConvert.SerializeObject(branchData.Select(x => x.BranchName).ToArray());
            ViewBag.ChartSales = Newtonsoft.Json.JsonConvert.SerializeObject(branchData.Select(x => x.TotalSales).ToArray());
            ViewBag.ChartProfits = Newtonsoft.Json.JsonConvert.SerializeObject(branchData.Select(x => x.NetProfit).ToArray());
            ViewBag.ChartExpenses = Newtonsoft.Json.JsonConvert.SerializeObject(branchData.Select(x => x.TotalExpenses).ToArray());

            return View("~/Views/Report/PharmacistSales.cshtml", branchData);
        }
    }
}
