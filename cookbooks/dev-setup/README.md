dev-setup Cookbook
==================
Installs and configures dev VM with Oracle technology stack.


Requirements
------------
artifacts
* jdk-7u45-linux-x64.tar.gz
* wls_121200.jar
* saucy-server-cloudimg-amd64-vagrant-disk1.box


Attributes
----------


Usage
-----
#### dev-setup::default
Just include `dev-setup` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[dev-setup]"
  ]
}
```


Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github


License and Authors
-------------------
Authors: Gary A. Stafford
