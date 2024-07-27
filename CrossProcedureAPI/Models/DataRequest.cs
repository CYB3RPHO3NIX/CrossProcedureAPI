namespace CrossProcedureAPI.Models
{
    public class DataRequest
    {
        public string RequestJson { get; set; }
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
    }
}
