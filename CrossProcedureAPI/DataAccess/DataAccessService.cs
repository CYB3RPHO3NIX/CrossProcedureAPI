using CrossProcedureAPI.DataAccess;
using Dapper;
using System.Data;
using System.Data.SqlClient;

namespace CrossProcedureAPI.DataAccess
{
    public class DataAccessService : IDataAccessService
    {
        private readonly string _connectionString;

        public DataAccessService(string connectionString)
        {
            _connectionString = connectionString;
        }

        public DataTable ExecuteStoredProcedure(string procedureName, DynamicParameters parameters)
        {
            var dataTable = new DataTable();



            using (IDbConnection db = new SqlConnection(_connectionString))
            {
                db.Open();
                try
                {
                    using (var reader = db.ExecuteReader(procedureName, parameters, commandType: CommandType.StoredProcedure))
                    {
                        if (reader.Read())
                        {
                            string firstResult = reader.GetString(0); // Assuming the first column is of type string
                        }

                        if (reader.NextResult() && reader.Read())
                        {
                            string secondResult = reader.GetString(0); // Assuming the first column is of type string
                        }
                    }
                } catch (Exception ex)
                {
                    
                }
            }
            return dataTable;
        }
    }
}
