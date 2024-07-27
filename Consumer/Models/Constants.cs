using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Consumer.Models
{
    public enum CrossProcedureObjectTypes
    {
        CountOf,
        CountOfRange,
        Equal,
        GreaterThanOrEqualTo,
        LessThanOrEqualTo,
        NotEqual,
        Range,
        ShouldContain,
        ShouldNotContain
    }
    public enum SortDirections
    {
        Ascending,
        Descending
    }


}
