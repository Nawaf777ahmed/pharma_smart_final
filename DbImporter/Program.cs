using System;
using System.IO;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;

namespace DbImporter
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("=============================================");
            Console.WriteLine("  🚀 بدء عملية استيراد قاعدة البيانات ...");
            Console.WriteLine("=============================================");

            string connectionString = Environment.GetEnvironmentVariable("DATABASE_URL") 
                ?? throw new InvalidOperationException("DATABASE_URL environment variable is not set.");

            string sqlFilePath = "../dblast3.sql";

            if (!File.Exists(sqlFilePath))
            {
                Console.WriteLine($"[خطأ] الملف {sqlFilePath} غير موجود!");
                return;
            }

            Console.WriteLine("[1/3] قراءة ملف SQL...");
            string scriptText = await File.ReadAllTextAsync(sqlFilePath);
            scriptText = "SET SESSION sql_require_primary_key = 0;\n" + scriptText;

            Console.WriteLine("[2/3] الاتصال بقاعدة بيانات Aiven السحابية...");
            try
            {
                using var connection = new MySqlConnection(connectionString);
                await connection.OpenAsync();

                Console.WriteLine("[3/3] جاري استيراد البيانات وإضافة الجداول...");
                var script = new MySqlScript(connection, scriptText);
                int statementsExecuted = await script.ExecuteAsync();

                Console.WriteLine($"✅ انتهت العملية بنجاح! تم استيراد بياناتك بالكامل ({statementsExecuted} تعليمة).");
            }
            catch (Exception ex)
            {
                Console.WriteLine("\n[خطأ فادح] فشل الاتصال أو الاستيراد:");
                Console.WriteLine(ex.Message);
            }
        }
    }
}
