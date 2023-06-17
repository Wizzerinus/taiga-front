module = angular.module("taigaTeam")
mixOf = @.taiga.mixOf
debounceLeading = @.taiga.debounceLeading
bindMethods = @.taiga.bindMethods

class EmployeeLogController extends mixOf(taiga.Controller, taiga.PageMixin, taiga.FiltersMixin)
    @.$inject = [
        "$scope",
        "tgProjectService",
        "$routeParams",
        "$translate",
        "tgAppMetaService",
        "$tgEvents",
        "$tgResources",
        "tgErrorHandlingService",
    ]

    constructor: (@scope, @projectService, @params, @translate, @appMetaService, @events, @rs,
                  @errorHandlingService) ->
        bindMethods(@)

        @.data = []
        @showTags = true
        @scope.sectionName = @translate.instant("PROJECT.SECTION.EMPLOYEE_LOG")

        promise = @.loadInitialData()

        # On Success
        promise.then =>
            title = @translate.instant("EMPLOYEE_LOG.PAGE_TITLE", {projectName: @scope.project.name})
            description = @translate.instant("ISSUES.PAGE_DESCRIPTION", {
                projectName: @scope.project.name,
                projectDescription: @scope.project.description
            })
            @appMetaService.setAll(title, description)

        # On Error
        promise.then null, @.onInitialDataError.bind(@)

    loadProject: ->
        project = @projectService.project.toJS()

        if not project.is_employee_log_activated
            @errorHandlingService.permissionDenied()

        @scope.projectId = project.id
        @scope.project = project
        @scope.$emit('project:loaded', project)

        return project

    initializeSubscription: ->
        routingKey = "changes.project.#{@scope.projectId}.employeelog.#{@scope.employeeId}"
        @events.subscribe @scope, routingKey, debounceLeading(500, (message) =>
            @.loadEmployeeLog())

    loadInitialData: ->
        project = @.loadProject()

        @.fillUsersAndRoles(project.members, project.roles)
        @.initializeSubscription()

        return @.loadEmployeeLog()

    # Blatant copy paste from issue code
    # We need to guarantee that the last petition done here is the finally used
    # When searching by text loadEmployeeLog can be called fastly with different parameters and
    # can be resolved in a different order than generated
    # We count the requests made and only if the callback is for the last one data is updated
    loadEmplogRequests: 0
    loadEmployeeLog: ->
        promise = @rs.employeeLog.list(@scope.projectId, @params.userslug || "")
        @.loadEmplogRequests += 1
        promise.index = @.loadEmplogRequests
        promise.then (data) =>
            if promise.index == @.loadEmplogRequests
                @.data = data

        return promise

    ###
    TODO: make the log sortable (needs quite a bit of work)
    getIssuesOrderBy: ->
        if _.isString(@location.search().order_by)
            return @location.search().order_by
        else
            return "created_date"
    ###

module.controller("EmployeeLogController", EmployeeLogController)
