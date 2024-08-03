using CrossProcedureAPI.DataAccess;
using CrossProcedureAPI.Models;
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

        public CombinedResult ExecuteStoredProcedure(string procedureName, DynamicParameters parameters)
        {
            var dataTable = new DataTable();
            CombinedResult cbr = new CombinedResult();
            using (IDbConnection db = new SqlConnection(_connectionString))
            {
                db.Open();
                try
                {
                    using (var reader = db.ExecuteReader(procedureName, parameters, commandType: CommandType.StoredProcedure))
                    {
                        if (reader.Read())
                        {
                            cbr.DataResult = reader.GetString(0); // Assuming the first column is of type string
                        }

                        if (reader.NextResult() && reader.Read())
                        {
                            cbr.CountResult = reader.GetString(0); // Assuming the first column is of type string
                        }
                    }
                }
                catch (Exception ex)
                {
                }
            }
            return cbr;
        }
    }
}