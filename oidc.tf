resource "aws_iam_openid_connect_provider" "github" {
    url = "https://token.actions.githubsercontent.com"
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"  // AWS Iam Role ကို tempory credential ခဏသုံးမယ့်လို့ပြောတယ့် action
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn  //Github ကလာတာတွေကိုပဲခွင့်ပြုတယ်
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:pyaephyoe783/-aws_terraform_1:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  role = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
  description = "The ARN of the github actions Iam Role For OIDC"
}