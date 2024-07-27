using Consumer.Models;
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
        public string ObjectName { get; set; }
        public List<dynamic> Filters { get; set; }
        public List<dynamic> CountQuery { get; set; }
        public List<dynamic> Sorting { get; set; }

        public string Build()
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder CountOf(string identifier, string columnName, string value)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder CountOfRange(string identifier, string columnName, string lValue, string hValue)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder Equal(string columnName, List<string> values)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder GreaterThanOrEqualTo(string columnName, string value)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder LessThanOrEqualTo(string columnName, string value)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder NotEqual(string columnName, List<string> values)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder Range(string columnName, string lValue, string hValue)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder SelectThis(string schemaName, string viewName)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder ShouldContain(string columnName, List<string> values)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder ShouldNotContain(string columnName, List<string> values)
        {
            throw new NotImplementedException();
        }

        public IQueryBuilder SortBy(string columnName, SortDirections sortDirection)
        {
            throw new NotImplementedException();
        }
    }
}
