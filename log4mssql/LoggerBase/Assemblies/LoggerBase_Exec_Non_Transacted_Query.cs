using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using System.Threading;
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

public class ReadWriteFiles
{
  [Microsoft.SqlServer.Server.SqlProcedure]
  public static void WriteTextFile(SqlString text,
                                        SqlString path,
                                        SqlBoolean append,
										out SqlInt32 exitCode,
										out SqlString errorMessage)
  {
    // Parameters
    // text: Contains information to be written.
    // path: The complete file path to write to.
    // append: Determines whether data is to be appended to the file.
    // if the file exists and append is false, the file is overwritten.
    // If the file exists and append is true, the data is appended to the file.
    // Otherwise, a new file is created.
	errorMessage = new SqlString(string.Empty);
    try
    {
      // Check for null input.
      if (!text.IsNull &&
          !path.IsNull &&
          !append.IsNull)
      {
        // Get the directory information for the specified path.
        var dir = Path.GetDirectoryName(path.Value);
        // Determine whether the specified path refers to an existing directory.
        if (!Directory.Exists(dir))
          // Create all the directories in the specified path.
          Directory.CreateDirectory(dir);
        // Initialize a new instance of the StreamWriter class
        // for the specified file on the specified path.
        // If the file exists, it can be either overwritten or appended to.
        // If the file does not exist, create a new file.
        using (var sw = new StreamWriter(path.Value, append.Value))
        {
          // Write specified text followed by a line terminator.
          sw.WriteLine(text);
        }
        // Return true on success.
       
		exitCode = new SqlInt32(0);
      }
      else
        // Return null if any input is null.
		exitCode = new SqlInt32(1);
    }
    catch (Exception ex)
    {
      // Return null on error.
	  //SqlContext.Pipe.Send(ex.Message);
	  errorMessage = new SqlString(ex.Message);
      //return -1 #SqlBoolean.True;
	  exitCode = new SqlInt32(-1);
    }
  }
  [SqlProcedure]
  public static void ReadTextFile(SqlString path)
  {
    // Parameters
    // path: The complete file path to read from.
    try
    {
      // Check for null input.
      if (!path.IsNull)
      {
        // Initialize a new instance of the StreamReader class for the specified path.
        using (var sr = new StreamReader(path.Value))
        {
          // Create the record and specify the metadata for the column.
          var rec = new SqlDataRecord(
                            new SqlMetaData("Line", SqlDbType.NVarChar, SqlMetaData.Max));
          // Mark the beginning of the result-set.
          SqlContext.Pipe.SendResultsStart(rec);
          // Determine whether the end of the file.
          while (sr.Peek() >= 0)
          {
            // Set value for the column.
            rec.SetString(0, sr.ReadLine());
            // Send the row back to the client.
            SqlContext.Pipe.SendResultsRow(rec);
          }
          // Mark the end of the result-set.
          SqlContext.Pipe.SendResultsEnd();
        }
      }
    }
    catch (Exception ex)
    {
      // Send exception message on error.
      SqlContext.Pipe.Send(ex.Message);
    }
  }
};

public class WriteFilesWithMutex
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void WriteTextFile(SqlString text,
                                          SqlString path,
                                          SqlBoolean append,
                                          SqlString mutexname,
                                          out SqlInt32 exitCode,
                                          out SqlString errorMessage)
    {
        errorMessage = new SqlString(string.Empty);
        try
        {
            // Check for null input.
            if (!text.IsNull &&
                !path.IsNull &&
                !append.IsNull)
            {
                // Get the directory information for the specified path.
                var dir = Path.GetDirectoryName(path.Value);
                // Determine whether the specified path refers to an existing directory.
                if (!Directory.Exists(dir))
                    // Create all the directories in the specified path.
                    Directory.CreateDirectory(dir);
                // Initialize a new instance of the StreamWriter class
                // for the specified file on the specified path.
                // If the file exists, it can be either overwritten or appended to.
                // If the file does not exist, create a new file.
                using (var mutex = new Mutex(false, mutexname.Value))
                {
                    mutex.WaitOne();
                    using (var sw = new StreamWriter(path.Value, append.Value))
                    {
                        // Write specified text followed by a line terminator.
                        sw.WriteLine(text);
                    }
                    mutex.ReleaseMutex();
                }
                // Return true on success.

                exitCode = new SqlInt32(0);
            }
            else
                // Return null if any input is null.
                exitCode = new SqlInt32(1);
        }
        catch (Exception ex)
        {
            // Return null on error.
            //SqlContext.Pipe.Send(ex.Message);
            errorMessage = new SqlString(ex.Message);
            //return -1 #SqlBoolean.True;
            exitCode = new SqlInt32(-1);
        }
    }
}