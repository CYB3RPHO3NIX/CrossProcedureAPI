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
            using (IDbConnection db = new SqlConnection(_connectionString))
            {
                db.Open();
                using (var reader = db.ExecuteReader(procedureName, parameters, commandType: CommandType.StoredProcedure))
                {
                    var dataTable = new DataTable();
                    dataTable.Load(reader);
                    return dataTable;
                }
            } 
        }
    }
}
