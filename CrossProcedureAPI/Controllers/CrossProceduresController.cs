using CrossProcedureAPI.Bootstrap;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CrossProcedureAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CrossProceduresController : ControllerBase
    {
        private IProcedureInstallerService _procedureInstallerService;
        public CrossProceduresController(IServiceProvider serviceProvider)
        {
            _procedureInstallerService = serviceProvider.GetRequiredService<IProcedureInstallerService>();
        }
        [HttpGet]
        public IActionResult GetData() 
        {
            try
            {
                _procedureInstallerService.InstallAllProcedures();
            }
            catch(Exception ex)
            {

            }
            return Ok();
        }
    }
}
