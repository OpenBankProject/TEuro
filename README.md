# TEuro

Copyright (C) 2022 - 2023 TESOBE GmbH


# Rationale
Create a blockchain stable coin who’s full and complete ownership graph is forever transparent and traceable to KYC’d legal persons or entities.

Why: Reduce corruption and create networks of values.

# Properties

* TEuros can only be transferred between addresses that have confirmed Know your Customer (KYC) information.
* The KYC information of addresses are validated by certified institutions such as large banks or national ID schemes.
* Each transaction records the KYC information (legal name) of both the from and to address at the time of the transaction
* The number of TEuros will be variable and will match Euros reserves. The quantity will start small.
* The value of a TEuro will be pegged to the Euro

# Status

The codebase is work in progress. We don't yet have any code for stable issuing or proof of reserve.

# Code

This module contains three packages that enable the full functionalities for the token.
The packages are divided as follows:

1. **api-package**: Which defines a mock API to mimick what an identity provider would offer.
2. **contract-package**: Which contains the smart contracts for the token.
3. **airnode-package**: Which contains the airnode definition and the tools to deploy it.

For more details about each package read the README.md file in each of them.

