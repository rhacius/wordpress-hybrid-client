md5 = require 'MD5'

module.exports = angular.module('wordpress-hybrid-client.taxonomies').factory '$WPHCTaxonomies', ($log, $filter, $wpApiTaxonomies, $q, $WPHCConfig, DSCacheFactory) ->
    $log.info '$WPHCTaxonomies'

    getCache = () ->
        if DSCacheFactory.get 'taxonomies'
            return DSCacheFactory.get 'taxonomies'
        DSCacheFactory 'taxonomies', $WPHCConfig.taxonomies.cache

    getTitle: (term, slug) ->
        trans = ''
        switch term
            when "post_tag"
                trans = if slug then 'title.tag' else 'title.tags'
            when "category"
                trans = if slug then 'title.category' else 'title.categories'
        $log.debug trans, term, '$WPHCTaxonomies getTitle'

        if slug
            $filter('translate') trans,
                name: slug
        else
            $filter('translate') trans

    getList: (term) ->
        deferred = $q.defer()
        hash = md5 $WPHCConfig.api.baseUrl + term
        listCache = getCache().get 'list-' + hash
        $log.debug listCache, 'Taxo cache'
        if listCache
            deferred.resolve listCache
        else
            $wpApiTaxonomies.$getTermList term
            .then (response) ->
                getCache().put 'list-' + hash, response
                deferred.resolve response
        deferred.promise
