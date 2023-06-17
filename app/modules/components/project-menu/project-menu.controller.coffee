###
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL
###

class ProjectMenuController
    @.$inject = [
        "tgProjectService",
        "tgLightboxFactory"
    ]

    constructor: (@projectService, @lightboxFactory) ->
        @.project = null
        @.menu = Immutable.Map()

    show: () ->
        @.project = @projectService.project
        @.sprints = @.project.get('milestones')?.toJS()
        @.active = @._getActiveSection()

        @.projectMenu = {
            component: 'tg-project-navigation',
            params: {
                project: @projectService.project.toJS(),
            },
            events: {
                search: () =>
                    @.search()
            }
        }

        @._setVideoConference()
        @._setMenuPermissions()

    hide: () ->
        @.project = null
        @.menu = {}

    search: () ->
        @lightboxFactory.create("tg-search-box", {
            "class": "lightbox lightbox-search"
        })

    _setVideoConference: () ->
        videoconferenceUrl = @._videoConferenceUrl()

        if videoconferenceUrl
            @.project = @.project.set("videoconferenceUrl", videoconferenceUrl)

    _setMenuPermissions: () ->
        @.menu = Immutable.Map({
            epics: false,
            backlog: false,
            kanban: false,
            issues: false,
            wiki: false
        })

        if @.project.get("is_epics_activated") && @.project.get("my_permissions").indexOf("view_epics") != -1
            @.menu = @.menu.set("epics", true)

        if @.project.get("is_backlog_activated") && @.project.get("my_permissions").indexOf("view_us") != -1
            @.menu = @.menu.set("backlog", true)

        if @.project.get("is_kanban_activated") && @.project.get("my_permissions").indexOf("view_us") != -1
            @.menu = @.menu.set("kanban", true)

        if @.project.get("is_issues_activated") && @.project.get("my_permissions").indexOf("view_issues") != -1
            @.menu = @.menu.set("issues", true)

        if @.project.get("is_wiki_activated") && @.project.get("my_permissions").indexOf("view_wiki_pages") != -1
            @.menu = @.menu.set("wiki", true)

        if @.project.get("is_employee_log_activated") && @.project.get("my_permissions").indexOf("is_employee") != -1
            @.menu = @.menu.set("employee-log", true)

    _getActiveSection: () ->
        sectionName = @projectService.section

        sectionsBreadcrumb = @projectService.sectionsBreadcrumb

        indexBacklog = sectionsBreadcrumb.lastIndexOf("backlog")
        indexKanban = sectionsBreadcrumb.lastIndexOf("kanban")

        if indexBacklog != -1 || indexKanban != -1
            if indexKanban == -1 || indexBacklog > indexKanban
                oldSectionName = "backlog"
            else
                oldSectionName = "kanban"

        if  sectionName  == "backlog-kanban"
            if oldSectionName in ["backlog", "kanban"]
                sectionName = oldSectionName
            else if @.project.get("is_backlog_activated") && !@.project.get("is_kanban_activated")
                sectionName = "backlog"
            else if !@.project.get("is_backlog_activated") && @.project.get("is_kanban_activated")
                sectionName = "kanban"

        return sectionName

    _videoConferenceUrl: () ->
        # Get base url
        if @.project.get("videoconferences") == "whereby-com"
            baseUrl = "https://whereby.com/"
        else if @.project.get("videoconferences") == "talky"
            baseUrl = "https://talky.io/"
        else if @.project.get("videoconferences") == "jitsi"
            baseUrl = "https://meet.jit.si/"
        else if @.project.get("videoconferences") == "custom"
            return @.project.get("videoconferences_extra_data")
        else
            return ""

        # Add prefix to the chat room name if exist
        if @.project.get("videoconferences_extra_data")
            url = @.project.get("slug") + "-" + taiga.slugify(@.project.get("videoconferences_extra_data"))
        else
            url = @.project.get("slug")

        # Some special cases
        if @.project.get("videoconferences") == "jitsi"
            url = url.replace(/-/g, "")

        return baseUrl + url

angular.module("taigaComponents").controller("ProjectMenu", ProjectMenuController)
