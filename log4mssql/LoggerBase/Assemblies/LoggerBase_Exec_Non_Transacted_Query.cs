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

        XmlDocument ParameterXML = new XmlDocument();
        ParameterXML.Load(Parameters.CreateReader());

        foreach (XmlNode Node in ParameterXML.ChildNodes)
        {
            foreach (XmlNode ChildNode in Node.ChildNodes)
            {
                if (ChildNode.Attributes == null) { continue; }

                if (Debug.Value & ChildNode.Attributes["ParameterName"] != null)
                {
                    SqlContext.Pipe.Send(string.Format("Processing parameter '{0}' with a value of '{1}'.", ChildNode.Attributes["ParameterName"].Value, ChildNode.InnerText));
                }
                if (ChildNode.Attributes["ParameterName"] != null)
                {
                    SqlParameter NewParameter = Command.CreateParameter();
                    NewParameter.ParameterName = ChildNode.Attributes["ParameterName"].Value;
                    if (ChildNode.Attributes["DBType"] != null)
                    {
                        NewParameter.SqlDbType = (SqlDbType)Enum.Parse(typeof(SqlDbType), ChildNode.Attributes["DBType"].Value);
                    }

                    int size;

                    if (ChildNode.Attributes["Size"] != null)
                    {
                        if (Int32.TryParse(ChildNode.Attributes["Size"].Value, out size))
                        {
                            NewParameter.Size = size;
                        }
                    }

                    NewParameter.Value = ChildNode.InnerText;

                    Command.Parameters.Add(NewParameter);
                }
            }
        }

        //ParameterXML.

        //var ParameterReader = Parameters.CreateReader();
        //while (ParameterReader.Read())
        //{


        //    if (ParameterReader.NodeType == XmlNodeType.Element)
        //    {
        //        if (Debug.Value)
        //        {
        //            SqlContext.Pipe.Send(string.Format("Processing parameter '{0}' with a value of '{1}'.", ParameterReader.GetAttribute("parameterName"), ParameterReader.Value));
        //        }
        //        SqlParameter NewParameter = Command.CreateParameter();
        //        NewParameter.ParameterName = ParameterReader.GetAttribute("parameterName");
        //        NewParameter.SqlDbType = (SqlDbType)Enum.Parse(typeof(SqlDbType), ParameterReader.GetAttribute("dbType"));
        //        int size;

        //        if (Int32.TryParse(ParameterReader.GetAttribute("size"), out size))
        //        {
        //            NewParameter.Size = size;
        //        }

        //        Command.Parameters.Add(NewParameter);
        //    }
        //}

        using (SqlConnection Connection = new SqlConnection(ConnectionStringValue))
            {
                Connection.Open();
               
                Command.CommandType = CommandType.Text;
                Command.CommandText = QueryValue;
                Command.Connection = Connection;

                if (Debug.Value)
                {
                    SqlContext.Pipe.Send(string.Format("Connecting to {0} and sending query: {1}", Connection.Database, Command.CommandText));
                    foreach(SqlParameter P in Command.Parameters)
                    {
                        SqlContext.Pipe.Send(string.Format("Parameter: {0} Value: {1}",P.ParameterName, P.Value));
                    }
                }

                Command.ExecuteNonQuery();

                Connection.Close();
            }
    }
}
