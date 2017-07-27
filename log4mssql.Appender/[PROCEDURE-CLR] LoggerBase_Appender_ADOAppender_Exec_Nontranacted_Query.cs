using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class StoredProcedures
{
    [Microsoft.SqlServer.Server.SqlProcedure]
    public static void exec_non_transacted_query(SqlString ConnectionString, SqlString Query)
    {
        SqlCommand Command = new SqlCommand();
        string QueryString = Query.Value;
        string ConnectionStringString = ConnectionString.Value;

        using (SqlConnection Connection = new SqlConnection(ConnectionStringString))
        {
            Connection.Open();
            
            Command.CommandType = CommandType.Text;
            Command.CommandText = QueryString;
            Command.Connection = Connection;
            Command.ExecuteNonQuery();

            Connection.Close();
        }
    }
};

//C:\Program Files (x86)\Microsoft Visual Studio 14.0>c:\Windows\microsoft.net\Framework\v3.5\csc.exe /target:library /out:"C:\Working\Projects\log4tsql-orig\exec_non_tranacted_query.dll" "C:\Working\Projects\log4tsql-orig\exec_non_tranacted_query.cs"