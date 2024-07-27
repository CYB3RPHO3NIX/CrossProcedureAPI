using CrossProcedureAPI.Bootstrap;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CrossProcedureAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CrossProceduresController : ControllerBase
    {
        public CrossProceduresController(IServiceProvider serviceProvider)
        {
            
        }
        [HttpGet]
        public IActionResult GetData() 
        {
            
            return Ok();
        }
    }
}
