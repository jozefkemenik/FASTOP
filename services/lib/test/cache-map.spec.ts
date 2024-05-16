import {} from 'mocha'
import { should as chaiShould } from 'chai'

import { CacheMap } from '../src/cache-map'

const should = chaiShould()

describe('CacheMap test suite', function() {
    let cache: CacheMap<string, number>

    beforeEach(function() {
        cache = new CacheMap<string, number>(5, 2)
        cache.set('a', 1)
        cache.set('b', 2)
        cache.set('c', 3)
    })

    it('should retrieve the value previously stored with the key', function() {
        const value = cache.get('b')
        value.should.equal(2)
    })
    it('should store max cache size items', function() {
        cache.set('d', 11)
        cache.set('e', 12)
        cache.get('a').should.equal(1)
        cache.size.should.equal(5)
    })
    it('should clear oldest items when the cache is full', function() {
        cache.set('d', 11)
        cache.set('e', 12)
        cache.set('f', 13)
        should.equal(cache.get('a'), undefined)
        should.equal(cache.get('b'), undefined)
        cache.get('c').should.equal(3)
        cache.get('f').should.equal(13)
        cache.size.should.equal(4)
    })
})
