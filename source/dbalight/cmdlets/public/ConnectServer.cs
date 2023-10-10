using System.Management.Automation;
using Microsoft.SqlServer.Management.Smo;
using Microsoft.SqlServer.Management.Common;

namespace dbalight.cmdlets.general
{
    /// <summary>
    /// <para type="synopsis"></para>
    /// <para type="description"></para>
    /// </summary>
    [Cmdlet(VerbsCommunications.Connect, "Server")]
    public class ConnectServerCmdlet : Cmdlet
    {
        /// <summary>
        /// <para type="description">The name of the SQL Server the command will connect to.</para>
        /// </summary>
        [Parameter(Mandatory = true, Position = 0)]
        public string ServerInstance
        {
            get { return serverInstance; }
            set { serverInstance = value; }
        }
        private string serverInstance;

        [Parameter(Position = 1)]
        public PSCredential Credential
        {
            get { return sqlCredential; }
            set { sqlCredential = value; }
        }
        private PSCredential sqlCredential;

        protected override void BeginProcessing()
        {
            WriteVerbose("Creating connection to ServerInstance: " + serverInstance);
        }

        protected override void ProcessRecord()
        {
            // Build Server connection details
            ServerConnection srvCn = new ServerConnection();

            // Check if Credential parameter was specified
            if (Credential != null)
            {
                // If Credential parameter was specified, use it to connect to the SQL Server instance
                srvCn.LoginSecure = false;
                srvCn.Login = Credential.UserName;
                srvCn.SecurePassword = Credential.Password;
            }
            else
            {
                WriteVerbose("Credential was not provided, defaulting to Windows Authentication");
                // If Credential parameter was not specified, use Windows Authentication to connect to the SQL Server instance
                srvCn.LoginSecure = true;
            }
            // Connect to the SQL Server instance specified by the Path parameter
            Server srv = new Server(srvCn);
            WriteVerbose("Server object created");
            WriteObject(srv, true);
        }
    }
}