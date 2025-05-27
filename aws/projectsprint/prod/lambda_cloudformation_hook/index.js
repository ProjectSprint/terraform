const {
  IAMClient,
  AttachRolePolicyCommand,
  GetRoleCommand,
} = require("@aws-sdk/client-iam");
const {
  CloudFormationClient,
  DescribeStackResourcesCommand,
} = require("@aws-sdk/client-cloudformation");

const iamClient = new IAMClient();
const cfnClient = new CloudFormationClient();

async function attachPolicyToRole(roleName) {
  const policyArn = process.env.POLICY_ARN;
  if (!policyArn) {
    throw new Error("POLICY_ARN environment variable not set");
  }

  try {
    // First check if the role exists
    await iamClient.send(new GetRoleCommand({ RoleName: roleName }));

    // Attach the policy
    await iamClient.send(
      new AttachRolePolicyCommand({
        RoleName: roleName,
        PolicyArn: policyArn,
      }),
    );

    console.log(
      `Successfully attached policy ${policyArn} to role ${roleName}`,
    );
  } catch (error) {
    console.error(`Error with role ${roleName}:`, error);
  }
}

async function getStackDetails(stackId) {
  try {
    // Get stack resources
    const resourcesResponse = await cfnClient.send(
      new DescribeStackResourcesCommand({
        StackName: stackId,
      }),
    );

    return {
      resources: resourcesResponse.StackResources,
    };
  } catch (error) {
    console.error("Error getting stack details:", error);
    throw error;
  }
}

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  try {
    // Handle CloudFormation stack status change
    const stackId = event.detail["stack-id"];
    const status = event.detail["status-details"].status;

    console.log(`Stack ${stackId} status changed to ${status}`);

    // Get detailed information about the stack
    const stackDetails = await getStackDetails(stackId);

    // Log detailed information
    console.log(
      "Stack Resources:",
      JSON.stringify(stackDetails.resources, null, 2),
    );

    const copilotCfnRole = stackDetails.resources.filter(
      (resource) =>
        resource.ResourceType === "AWS::IAM::Role" &&
        resource.PhysicalResourceId.endsWith("CFNExecutionRole"),
    );
    if (copilotCfnRole.length) {
      console.log(
        "copilotCfnRole detected!:",
        JSON.stringify(copilotCfnRole, null, 2),
      );
      const roleName = copilotCfnRole[0].PhysicalResourceId;
      await attachPolicyToRole(roleName);
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Processed event successfully",
      }),
    };
  } catch (error) {
    console.error("Error:", error);
    throw error;
  }
};
