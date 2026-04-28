using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmaSmartWeb.Models
{
    [Table("userscreenpermissions")]
    public partial class UserScreenPermissions
    {
        [Key]
        [Column("PermissionID", TypeName = "int(11)")]
        public int PermissionId { get; set; }
        
        [Column("UserID", TypeName = "int(11)")]
        public int UserId { get; set; }
        
        [Column("ScreenID", TypeName = "int(11)")]
        public int ScreenId { get; set; }
        
        public bool CanView { get; set; }
        public bool CanAdd { get; set; }
        public bool CanEdit { get; set; }
        public bool CanDelete { get; set; }
        public bool CanPrint { get; set; }

        [ForeignKey(nameof(UserId))]
        [InverseProperty(nameof(Users.UserScreenPermissions))]
        public virtual Users User { get; set; }
        
        [ForeignKey(nameof(ScreenId))]
        [InverseProperty(nameof(Systemscreens.UserScreenPermissions))]
        public virtual Systemscreens Screen { get; set; }
    }
}
