using Microsoft.EntityFrameworkCore.Migrations;

namespace PharmaSmartWeb.Migrations
{
    public partial class AddOfflineLocalIdToSales : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "OfflineLocalId",
                table: "sales",
                type: "varchar(100)",
                nullable: true);

            migrationBuilder.Sql("CREATE UNIQUE INDEX IF NOT EXISTS IX_sales_BranchID_OfflineLocalId ON sales (BranchID, OfflineLocalId);");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DROP INDEX IF EXISTS IX_sales_BranchID_OfflineLocalId;");
            migrationBuilder.DropColumn(
                name: "OfflineLocalId",
                table: "sales");
        }
    }
}
