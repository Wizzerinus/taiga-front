###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

taiga = @.taiga

generateHash = taiga.generateHash

resourceProvider = ($repo, $storage) ->
    service = {}
    hashSuffix = "emplog-queryparams"

    service.storeQueryParams = (projectId, employeeId, params) ->
        ns = "#{projectId}:#{hashSuffix}"
        hash = generateHash([projectId, employeeId, ns])
        $storage.set(hash, params)

    service.list = (projectId, employeeId, filters, options) ->
        params = {project: projectId, employeeId: employeeId}
        params = _.extend({}, params, filters or {})
        service.storeQueryParams(projectId, employeeId, params)
        return $repo.queryMany("employee-log", params, options)

    return (instance) ->
        instance.employeeLog = service


module = angular.module("taigaResources")
module.factory("$tgEmployeeLogResourcesProvider", ["$tgRepo", "$tgStorage", resourceProvider])
