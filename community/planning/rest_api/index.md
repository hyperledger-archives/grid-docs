# Proposed Future REST API Reference

<!--
  Copyright 2018-2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->


This document is intended to capture proposed updates to the Grid REST API.
This document is a work-in-progress and proposed changes may or may not be
implemented as project requirements evolve.

* [Future REST API Reference](/community/planning/rest_api/api/)

## Changes

  - Added `POST` and `PUT` routes for various Grid resources. These endpoints
  will be used to submit batches to create and update resources. This takes the
  place of submitting everything through a `POST` to `/batches` and will
  provide users with a more familiar REST API experience.
  - Updated resource schemas. The resource schemas for various Grid features
  have been updated to reflect their protobuf message counterparts and what a
  user can expect to see when fetching that resource. Some resources do not
  differ between their create and update messages and have not changed.
  - Removed Track and Trace endpoints. This feature will no longer be supported.

## For further consideration

  - Consider changing `/batch_statuses` to `/batch-statuses`. This would bring
  this endpoint in line with other endpoints in this API but consideration must
  be given to the impact this will have on the corresponding endpoints in
  Sawtooth and Splinter as well as backwards-compatibility concerns.
