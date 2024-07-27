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
        public async Task<IActionResult> GetData() 
        {
            List<object> objs = new List<object>();
            objs.Add(new { Name = "Jonathan", Age = 21 });
            objs.Add(new { Friends = new List<object>() 
            {
                new { Name = "Maverick", Age = 25 },
                new { Name = "David", Age = 27 },
                new { Name = "Martinez", Age = 23 }
            } });

            return Ok(System.Text.Json.JsonSerializer.Serialize(objs));
        }
    }
}
