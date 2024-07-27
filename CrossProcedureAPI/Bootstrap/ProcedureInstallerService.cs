
using CrossProcedureAPI.Models.Bootstrap;
using Dapper;
using System.Data.SqlClient;
using System.Diagnostics.Contracts;

namespace CrossProcedureAPI.Bootstrap
{
    public class ProcedureInstallerService : IProcedureInstallerService
    {
        public bool IsAllProceduresInstalled { get; private set; }

        private readonly string _connectionString;
        private readonly string _scriptsDirectory;

        private List<string> _storedProcedures;
        public ProcedureInstallerService(string connectionString)
        {
            _connectionString = connectionString;
            _scriptsDirectory = Directory.GetCurrentDirectory() + "\\Scripts";
            InitializeScripts();
        }
        
        private void ExecuteScript(string script)
        {
            using (SqlConnection connection = new SqlConnection(_connectionString))
            {
                connection.Open();

                using (SqlCommand command = new SqlCommand(script, connection))
                {
                    command.ExecuteNonQuery();
                }
            }
        }
        private void InitializeScripts()
        {
            _storedProcedures = new List<string>();
            _storedProcedures.Add(StoredProcedures.PROC_CountOf);
            _storedProcedures.Add(StoredProcedures.PROC_CrossProcedure);
            _storedProcedures.Add(StoredProcedures.PROC_ShouldContain);
            _storedProcedures.Add(StoredProcedures.PROC_Equals);
            _storedProcedures.Add(StoredProcedures.PROC_LessThanOrEqualTo);
            _storedProcedures.Add(StoredProcedures.PROC_Range);
            _storedProcedures.Add(StoredProcedures.PROC_ShouldNotContain);
            _storedProcedures.Add(StoredProcedures.PROC_CountOfRange);
            _storedProcedures.Add(StoredProcedures.PROC_GreaterThanOrEqualTo);
            _storedProcedures.Add(StoredProcedures.PROC_NotEqual);
        }
        private string ReadScripts(string scriptName)
        {
            string filePath = Path.Combine(_scriptsDirectory, scriptName);
            string script = File.ReadAllText(filePath);
            return script;
        }
        public bool IsAlreadyExists(string procedureName)
        {
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();

                var query = @"
                SELECT COUNT(*)
                FROM sys.objects
                WHERE type = 'P' AND name = @ScriptName";

                int count = connection.QuerySingleOrDefault<int>(query, new { ScriptName = procedureName });

                return count > 0;
            }
        }
        public void InstallAllProcedures()
        {
            foreach(var procedure in _storedProcedures) 
            {
                if (!IsAlreadyExists(procedure.Split('.')[0].ToString()))
                {
                    string script = ReadScripts(procedure);
                    ExecuteScript(script);
                }
            }
        }
    }
}
