using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmaSmartWeb.Models
{
    [Table("shifts")]
    public partial class Shifts
    {
        public Shifts()
        {
            Sales = new HashSet<Sales>();
        }

        [Key]
        [Column("ShiftId", TypeName = "int(11)")]
        public int ShiftId { get; set; }

        [Column("BranchId", TypeName = "int(11)")]
        public int BranchId { get; set; }

        [Column("UserId", TypeName = "int(11)")]
        public int UserId { get; set; }

        [Column(TypeName = "datetime")]
        public DateTime OpenedAt { get; set; }

        [Column(TypeName = "datetime")]
        public DateTime? ClosedAt { get; set; }

        [Required]
        [StringLength(20)]
        public string Status { get; set; } = "Open";

        [Column(TypeName = "decimal(18,2)")]
        public decimal OpeningBalance { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal ExpectedCash { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal ActualCash { get; set; } = 0;

        [Column(TypeName = "decimal(18,2)")]
        public decimal Difference { get; set; } = 0;

        public string? Notes { get; set; }

        [ForeignKey(nameof(BranchId))]
        [InverseProperty(nameof(Branches.Shifts))]
        public virtual Branches Branch { get; set; }

        [ForeignKey(nameof(UserId))]
        [InverseProperty(nameof(Users.Shifts))]
        public virtual Users User { get; set; }

        [InverseProperty("Shift")]
        public virtual ICollection<Sales> Sales { get; set; }
    }
}
