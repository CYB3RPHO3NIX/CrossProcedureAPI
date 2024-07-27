using Dapper;
using System.Data;

namespace CrossProcedureAPI.DataAccess
{
    public interface IDataAccessService
    {
        DataTable ExecuteStoredProcedure(string procedureName, DynamicParameters parameters);
    }
}
