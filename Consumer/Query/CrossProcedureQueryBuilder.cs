using Consumer.Models;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Consumer.Query
{
    public interface IQueryBuilder
    {
        IQueryBuilder SelectThis(string schemaName, string viewName);

        //Filters
        IQueryBuilder Equal(string columnName, List<string> values);

        IQueryBuilder GreaterThanOrEqualTo(string columnName, string value);

        IQueryBuilder LessThanOrEqualTo(string columnName, string value);

        IQueryBuilder NotEqual(string columnName, List<string> values);

        IQueryBuilder Range(string columnName, string lValue, string hValue);

        IQueryBuilder ShouldContain(string columnName, List<string> values);

        IQueryBuilder ShouldNotContain(string columnName, List<string> values);

        //Counts
        IQueryBuilder CountOf(string identifier, string columnName, string value);

        IQueryBuilder CountOfRange(string identifier, string columnName, string lValue, string hValue);

        //Sorting
        IQueryBuilder SortBy(string columnName, SortDirections sortDirection);

        string Build();
    }

    public class CrossProcedureQueryBuilder : IQueryBuilder
    {
        public JObject ObjectName { get; set; }
        public List<JObject> Filters { get; set; } = new List<JObject>();
        public List<JObject> CountQuery { get; set; } = new List<JObject>();
        public List<JObject> Sorting { get; set; } = new List<JObject>();

        public string Build()
        {
            if (ObjectName == null) throw new ArgumentNullException();

            JObject rootObject = new JObject(
                new JProperty("Object", ObjectName)
            );
            if (Filters.Count > 0)
            {
                rootObject.Add(new JProperty("Query", Filters));
            }
            if (CountQuery.Count > 0)
            {
                rootObject.Add(new JProperty("Count", CountQuery));
            }
            if (Sorting.Count > 0)
            {
                rootObject.Add(new JProperty("Sort", Sorting));
            }
            return rootObject.ToString(formatting: Formatting.None);
        }

        public IQueryBuilder CountOf(string identifier, string columnName, string value)
        {
            CountQuery.Add(new JObject
            {
                new JProperty("Type", "CountOf"),
                new JProperty("Identifier", identifier),
                new JProperty("ColumnName", columnName),
                new JProperty("Value", value)
            });

            return this;
        }

        public IQueryBuilder CountOfRange(string identifier, string columnName, string lValue, string hValue)
        {
            CountQuery.Add(new JObject
            {
                new JProperty("Type", "CountOfRange"),
                new JProperty("Identifier", identifier),
                new JProperty("ColumnName", columnName),
                new JProperty("lValue", lValue),
                new JProperty("hValue", hValue)
            });

            return this;
        }

        public IQueryBuilder Equal(string columnName, List<string> values)
        {
            Filters.Add(new JObject()
            {
                new JProperty("FilterType", "Equals"),
                new JProperty("ColumnName", columnName),
                new JProperty("Value", new JArray(values))
            });
            return this;
        }

        public IQueryBuilder GreaterThanOrEqualTo(string columnName, string value)
        {
            Filters.Add(new JObject()
            {
                new JProperty("FilterType", "GreaterThanOrEqualTo"),
                new JProperty("ColumnName", columnName),
                new JProperty("Value", value)
            });

            return this;
        }

        public IQueryBuilder LessThanOrEqualTo(string columnName, string value)
        {
            Filters.Add(new JObject()
            {
                new JProperty("FilterType", "LessThanOrEqualTo"),
                new JProperty("ColumnName", columnName),
                new JProperty("Value", value)
            });

            return this;
        }

        public IQueryBuilder NotEqual(string columnName, List<string> values)
        {
            Filters.Add(new JObject()
            {
                new JProperty("FilterType", "NotEqual"),
                new JProperty("ColumnName", columnName),
                new JProperty("Value", new JArray(values))
            });
            return this;
        }

        public IQueryBuilder Range(string columnName, string lValue, string hValue)
        {
            Filters.Add(new JObject()
            {
                new JProperty("FilterType", "Range"),
                new JProperty("ColumnName", columnName),
                new JProperty("lValue", lValue),
                new JProperty("hValue", hValue)
            });

            return this;
        }

        public IQueryBuilder SelectThis(string schemaName, string viewName)
        {
            ObjectName = new JObject()
            {
                new JProperty("SchemaName", schemaName),
                new JProperty("ViewName", viewName)
            };
            return this;
        }

        public IQueryBuilder ShouldContain(string columnName, List<string> values)
        {
            Filters.Add(new JObject()
            {
                new JProperty("FilterType", "ShouldContain"),
                new JProperty("ColumnName", columnName),
                new JProperty("Value", new JArray(values))
            });

            return this;
        }

        public IQueryBuilder ShouldNotContain(string columnName, List<string> values)
        {
            Filters.Add(new JObject()
            {
                new JProperty("FilterType", "ShouldNotContain"),
                new JProperty("ColumnName", columnName),
                new JProperty("Value", new JArray(values))
            });

            return this;
        }

        public IQueryBuilder SortBy(string columnName, SortDirections sortDirection)
        {
            Sorting.Add(new JObject()
            {
                new JProperty("ColumnName", columnName),
                new JProperty("SortDirection", (sortDirection == SortDirections.Ascending ? "asc" : "desc")),
            });

            return this;
        }
    }
}