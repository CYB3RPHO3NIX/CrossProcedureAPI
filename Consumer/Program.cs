using Consumer.Query;
using Newtonsoft.Json;
using System.Text;

namespace Consumer
{
    internal class Program
    {
        public static string endpoint = "https://localhost:7186/api/CrossProcedures";
        static void Main(string[] args)
        {
            CrossProcedureQueryBuilder builder = new CrossProcedureQueryBuilder();
            builder.SelectThis("HumanResources", "vEmployee");
            builder.ShouldContain("PhoneNumberType", ["Work"]);
            string query = builder.Build();
            Console.WriteLine($"Input Query:\n {query}");

            var requestObject = new { requestJson = query, pageNumber = 1, pageSize = 10 };

            var result = MakePostRequestAsync(requestObject).GetAwaiter().GetResult();

            Console.WriteLine($"Output from API: {result}");
            Console.ReadKey();
        }
        public static async Task<string> MakePostRequestAsync(object data)
        {
            using (HttpClient client = new HttpClient())
            {
                // Serialize the data to JSON
                string json = JsonConvert.SerializeObject(data);
                StringContent content = new StringContent(json, Encoding.UTF8, "application/json");

                // Send the POST request
                HttpResponseMessage response = await client.PostAsync(endpoint, content);

                // Ensure the request was successful
                response.EnsureSuccessStatusCode();

                // Read the response content as a string
                string responseBody = await response.Content.ReadAsStringAsync();

                return responseBody;
            }
        }
    }
}
