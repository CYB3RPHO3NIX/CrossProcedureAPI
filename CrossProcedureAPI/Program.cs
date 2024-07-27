using CrossProcedureAPI.Bootstrap;
using CrossProcedureAPI.DataAccess;

namespace CrossProcedureAPI
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            IConfiguration configuration = builder.Configuration;
            string connectionString = configuration.GetConnectionString("Database");


            builder.Services.AddControllers();
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();
            builder.Services.AddTransient<IDataAccessService>(provider => new DataAccessService(connectionString));
            builder.Services.AddScoped<IProcedureInstallerService>(provider => new ProcedureInstallerService(connectionString));

            var app = builder.Build();

            var res = GetFilesInFolder(Directory.GetCurrentDirectory()+"\\Scripts");

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            app.UseAuthorization();

            app.MapControllers();

            app.Run();
        }
        public static List<string> GetFilesInFolder(string folderPath)
        {
            try
            {
                // Ensure the folder exists
                if (!Directory.Exists(folderPath))
                {
                    throw new DirectoryNotFoundException($"The directory '{folderPath}' does not exist.");
                }

                // Get all file paths in the folder
                string[] files = Directory.GetFiles(folderPath);

                // Convert to List<string>
                List<string> fileList = new List<string>(files);

                return fileList;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
                return new List<string>(); // Return an empty list in case of error
            }
        }
    }
}
