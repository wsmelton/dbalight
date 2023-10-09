using System.Management.Automation;
using Microsoft.SqlServer.Management.Smo;
using Microsoft.SqlServer.Management.Common;

namespace dbalight.commands
{
    /// <summary>
    /// <para type="synopsis"></para>
    /// <para type="description"></para>
    /// </summary>
    [Cmdlet(VerbsCommunications.Connect, "Server")]
    public class ConnectServerCmdlet : PSCmdlet
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

        protected override void ProcessRecord()
        {
            // Build Server connection details
            ServerConnection srvCn = new ServerConnection();
            if (MyInvocation.BoundParameters.ContainsKey("Credential"))
            {
                // do something
            }
            // Connect to the SQL Server instance specified by the Path parameter
            Server srv = new Server(srvCn);

            // Write the value of the specified property to the output
            WriteObject(srv);
        }
    }
}