
# IMAS Data Dictionary

The Data Dictionary is the implementation of the Data Model of ITER's Integrated Modelling & Analysis Suite (IMAS). It describes the structuring and naming of data (as a set of Interface Data Structures or IDSs) being used for both simulated and experimental data in a machine agnostic manner.

IDSs are used for standardizing data representation, facilitating exploration and comparison, as well as for standardizing coupling interfaces between codes in an Integrated Modelling workflow. The Data Dictionary itself does not describe explicitly how the data will be stored on disk but is used at compile time or at runtime by various pieces of data access software (e.g. the [Access-Layer](https://git.iter.org/projects/IMAS/repos/access-layer) which handle data archiving and retrieval within applications.

IDSs of the Data Dictionary follow a strict lifecycle that aims at controlling the compatibility between various releases. This lifecycle is fully described in the following external document: [ITER_D_QQYMUK](https://user.iter.org/?uid=QQYMUK).

As it is generic and machine agnostic by design, the IMAS Data Model, and by extension its implementation as the Data Dictionary, have the potential to serve as a data standard for the fusion community. As such, it benefits from the wide involvement of specialists and active users and developers in the various areas being described. If you want to contribute to the improvement of the Data Dictionary, either as a developer, a specific system/area specilist or an occasional user providing feedback, please look at [CONTRIBUTING.md](CONTRIBUTING.md).




# Python installation
Data dictionary can be installed using python pip install. Following is the process for the same.
Generate idsdef.xml once files are checked out

```sh
git clone ssh://git@git.iter.org/imas/data-dictionary.git
cd data_dictionary
module load Saxon-HE/11.4-Java-11
pip install . [--user]

# Clean all files
python clean.py

# Testing
python test.py
```
# IDSDEF utility
once data dictionary is installed you can use idsdef functionality on the command prompt. 
It provides useful fetaures such as providing metadata, listing all variables, searching text in IDS fields etc.

## Usage
```sh
$ idsdef
usage: idsdef [-h] {idspath,metadata,idsnames,search,idsfields,info} ...

IDS Def Utilities

positional arguments:
  {idspath,metadata,idsnames,search,idsfields,info}
                        sub-commands help
    idspath             print ids definition path
    metadata            print metadata
    idsnames            print ids names
    search              Search in ids
    idsfields           shows all fields from ids
    info                Query the IDS XML Definition for documentation

optional arguments:
  -h, --help            show this help message and exit
```

## examples:
### Print data dictionary xml path
```sh
$ idsdef idspath
/home/ITER/username/.local/dd_3.38.1+15.g41c54bc.dirty/include/IDSDef.xml
```

### Show metadata abot data dictionary
```sh
$ idsdef metadata
This is Data Dictionary version = 3.38.1-15-g41c54bc, following COCOS = 11
```

### Search in ids fields
input: text to search
```sh
$ idsdef search neutron
Searching for 'neutron'.
neutron_diagnostic:
        detectors/green_functions/source_neutron_energies
        detectors/green_functions/source_neutron_energies_error_upper
        .
        .
        synthetic_signals/total_neutron_flux_error_upper
        synthetic_signals/total_neutron_flux_error_lower
        synthetic_signals/total_neutron_flux_error_index
summary:
        fusion/neutron_fluxes
        fusion/neutron_rates
        fusion/neutron_power_total
```

### Print all fields from IDS
input: ids name
```sh
$ idsdef idsfields amns_data
Listing all fields from ids :'amns_data'
ids_properties
ids_properties/comment
ids_properties/homogeneous_time
ids_properties/source
ids_properties/provider
ids_properties/creation_date
ids_properties/version_put
ids_properties/version_put/data_dictionary
ids_properties/version_put/access_layer
ids_properties/version_put/access_layer_language
ids_properties/provenance
ids_properties/provenance/node()
ids_properties/provenance/node()/path
ids_properties/provenance/node()/sources(:)
ids_properties/plugins
.
.
```

### Show information of IDS
```sh
$ idsdef info amns_data
Atomic, molecular, nuclear and surface physics data. Each occurrence contains the data for a given element (nuclear charge), describing various physical processes. For each process, data tables are organized by charge states. The coordinate system used by the data tables is described under the coordinate_system node.
```



