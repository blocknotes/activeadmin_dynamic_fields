# Development

## Releases

```sh
# Update lib/activeadmin/dynamic_fields/version.rb with the new version
# Update the gemfiles:
bin/appraisal
```

## Testing

```sh
# Running specs using a specific configuration:
bin/appraisal rails60-activeadmin22 rspec
# Using latest activeadmin version:
bin/appraisal rails60-activeadmin rspec
# See gemfiles for more configurations
```
