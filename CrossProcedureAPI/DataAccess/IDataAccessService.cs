using CrossProcedureAPI.Models;
using Dapper;
using System.Data;

namespace CrossProcedureAPI.DataAccess
{
    public interface IDataAccessService
    {
        CombinedResult ExecuteStoredProcedure(string procedureName, DynamicParameters parameters);
    }
}