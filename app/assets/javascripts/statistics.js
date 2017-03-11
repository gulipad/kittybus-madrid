$(document).ready(function () {
    var users_count_array = ($('#users').data().users)
    processData(users_count_array)
    $('#user-count-chart-select').on('change', function () {
        var select = $('#user-count-chart-select').val()
        console.log(select)
        $.post( "./stats", { value: select} )
            .then(function (response) {
                console.log(response.graph_data)
                processData(response.graph_data)
                
            }, function (reject) {
                console.error(reject)
            })

    })
})

function processData (users_count_array) {
    var users = []
    var months = []
    return users_count_array.forEach(function (month) {
        users.push(month.users)
        months.push(month.month)

        $(function () { 
        var myChart = Highcharts.chart('container', {
            chart: {
                type: 'line'
            },
            title: {
                text: 'User Growth in the Past ' + months.length + ' Months'
            },
            xAxis: {
                title: {
                    text: 'Month'
                },
                categories: months
            },
            yAxis: {
                title: {
                    text: 'Users'
                }
            },
            series: [{
                name: 'Users',
                data: users
            }]
        })
    })
    })
}