using CrossProcedureAPI.Bootstrap;
using CrossProcedureAPI.DataAccess;
using CrossProcedureAPI.Models;
using Dapper;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CrossProcedureAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CrossProceduresController : ControllerBase
    {
        private readonly IDataAccessService _dataAccessService;
        public CrossProceduresController(IServiceProvider serviceProvider)
        {
            _dataAccessService = serviceProvider.GetRequiredService<IDataAccessService>(); 
        }
        [HttpPost]
        public async Task<IActionResult> GetData(DataRequest request) 
        {
            if(string.IsNullOrEmpty(request.RequestJson))
            {
                return BadRequest();
            }
            DynamicParameters inputParams = new DynamicParameters();
            inputParams.Add("@Query", request.RequestJson, System.Data.DbType.String, System.Data.ParameterDirection.Input);
            inputParams.Add("@PageNumber", request.PageNumber, System.Data.DbType.Int32, System.Data.ParameterDirection.Input);
            inputParams.Add("@PageSize", request.PageSize, System.Data.DbType.Int32, System.Data.ParameterDirection.Input);
            var data = _dataAccessService.ExecuteStoredProcedure("dbo.CrossProcedure", inputParams);

            return Ok();
        }
    }
}
