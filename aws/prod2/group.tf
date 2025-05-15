resource "aws_iam_group" "root_developers" {
  name = "root-developers"
  path = "/root_developers/"
}

resource "aws_iam_group_membership" "root_team" {
  name  = "root-team"
  users = [data.aws_iam_user.current_user.user_name]
  group = aws_iam_group.root_developers.name
}