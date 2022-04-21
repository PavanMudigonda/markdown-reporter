# Markdown Reporter

Publishes the markdown file provided in GitHub Actions as Checkrun.

### Note:- The scope of this project is limited to publishing report.
###  If you like my Github Action, please **STAR ⭐** it.

## Samples


Here's a quick example of how to use this action in your own GitHub Workflows.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    
      - name: use this action, with existing test results
        uses: PavanMudigonda/markdown-reporter@v0.1
        with:
          markdown_path: README.md
          github_token: ${{ secrets.GITHUB_TOKEN }}
          report_name: readme please
          report_title: README FILE
                    
```


### Inputs

This Action defines the following formal inputs.

| Name | Req | Description
|-|-|-|
|**`markdown_path`**  | true | Markdown Path. 
|**`github_token`** | true | Input the GITHUB TOKEN Or Personal Access Token you would like to use. Recommended to use GitHub auto generated token ${{ secrets.GITHUB_TOKEN }}
|**`skip_check_run`** | true | If true, will skip attaching the Coverage Result report to the Workflow Run using a Check Run. 
|**`report_name`**  | true | Report name
|**`report_title`**  | true | Report Title



### Sample Screenshot


### Sample Github Actions workflow 



### PowerShell GitHub Action

This Action is implemented as a [PowerShell GitHub Action](https://github.com/ebekker/pwsh-github-action-base).
