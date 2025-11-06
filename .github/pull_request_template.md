## Description

<!-- Provide a clear and concise description of your changes -->

## Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Code refactoring
- [ ] CI/CD changes
- [ ] Security improvement

## Related Issue

<!-- Link to the issue this PR addresses -->
Fixes #(issue number)

## Changes Made

<!-- List the specific changes you made -->

- Change 1
- Change 2
- Change 3

## Testing

<!-- Describe the tests you ran and how to reproduce them -->

### Test Environment
- OS:
- Docker Version:
- Architecture:

### Tests Run

```bash
# Paste commands used to test your changes
bats tests/passwd_test.sh
docker build -t test .
```

### Test Results

<!-- Describe the results of your testing -->

- [ ] All existing tests pass
- [ ] New tests added (if applicable)
- [ ] Tested on multiple platforms (if applicable)

## Checklist

<!-- Mark completed items with an "x" -->

- [ ] My code follows the project's coding standards
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing tests pass locally with my changes
- [ ] I have updated CHANGELOG.md with my changes
- [ ] Any dependent changes have been merged and published

## Screenshots

<!-- If applicable, add screenshots to help explain your changes -->

## Security Considerations

<!-- If your changes have security implications, describe them here -->

- [ ] This change has security implications (explain below)
- [ ] This change has been reviewed for security issues
- [ ] No security concerns

## Breaking Changes

<!-- If this PR introduces breaking changes, describe them here -->

**Does this PR introduce breaking changes?**
- [ ] Yes (describe below)
- [ ] No

<!-- If yes, describe what breaks and what users need to do to adapt -->

## Additional Notes

<!-- Add any other context about the pull request here -->

## Reviewer Notes

<!-- Specific areas you'd like reviewers to focus on -->
