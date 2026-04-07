using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmaSmartWeb.Models
{
    [Table("saledetails")]
    public partial class Saledetails
    {
        [Key]
        [Column("SaleDetailID", TypeName = "int(11)")]
        public int SaleDetailId { get; set; }
        [Column("SaleID", TypeName = "int(11)")]
        public int SaleId { get; set; }
        [Column("DrugID", TypeName = "int(11)")]
        public int DrugId { get; set; }
        [Column(TypeName = "int(11)")]
        public int Quantity { get; set; }
        [Column(TypeName = "decimal(18,2)")]
        public decimal UnitPrice { get; set; }

        [ForeignKey(nameof(DrugId))]
        [InverseProperty(nameof(Drugs.Saledetails))]
        public virtual Drugs Drug { get; set; } = null!;
        [ForeignKey(nameof(SaleId))]
        [InverseProperty(nameof(Sales.Saledetails))]
        public virtual Sales Sale { get; set; } = null!;
    }
}
