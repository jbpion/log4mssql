using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Xml;
using Microsoft.SqlServer.Server;

public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void LoggerBase_Exec_Non_Transacted_Query(SqlString ConnectionString, SqlString Query, SqlXml Parameters, SqlInt32 CommandTimeout, SqlBoolean Debug)
    {
        SqlCommand Command = new SqlCommand();
        string QueryValue = Query.Value;
        string ConnectionStringValue = ConnectionString.Value + ";Enlist=false;";

        var ParameterReader = Parameters.CreateReader();
        while (ParameterReader.Read())
        {
            if (Debug.Value)
            {
                SqlContext.Pipe.Send(string.Format("Processing parameter {0} with a value of {1}.", ParameterReader.Name, ParameterReader.Value));
            }

            if (ParameterReader.NodeType.Equals(XmlNodeType.Element))
            {
                SqlParameter NewParameter = Command.CreateParameter();
                NewParameter.ParameterName = ParameterReader.GetAttribute("ParameterName");
                NewParameter.SqlDbType = (SqlDbType)Enum.Parse(typeof(SqlDbType), ParameterReader.GetAttribute("DBType"));
                Command.Parameters.Add(NewParameter);
            }

            using (SqlConnection Connection = new SqlConnection(ConnectionStringValue))
            {
                Connection.Open();

                Command.CommandType = CommandType.Text;
                Command.CommandText = QueryValue;
                Command.Connection = Connection;
                Command.ExecuteNonQuery();

                Connection.Close();
            }
        }
    }
}
