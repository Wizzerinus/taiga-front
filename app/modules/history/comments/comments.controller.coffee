###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

module = angular.module("taigaHistory")

class CommentsController
    @.$inject = []

    constructor: () ->

    initializePermissions: () ->
        if @.issueScope && @.issueScope != "undefined" && @.name == "issue" && @.issueScope != "normal"
            @.canAddCommentPermission = ['comment_' + @.name, 'edit_issues_' + @.issueScope].join(',')
        else
            @.canAddCommentPermission = 'comment_' + @.name

module.controller("CommentsCtrl", CommentsController)
