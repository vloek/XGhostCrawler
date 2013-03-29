#!/usr/bin/ruby
# encoding: utf-8
require 'wombat'

class XGhostCrawler

	def crawl
		971370.upto(972000) do |num|
			link = "http://zakupki.gov.ru/223/purchase/public/print-form/show.html?pfid=#{num}"
			begin
				doc = Wombat.crawl do
					base_url "#{link}"
					user_agent_alias 'Mac Safari'

					# НОМЕР ИЗВЕЩЕНИЯ
					title css: '#tabs-2' do |data|
						XGhostCrawler.rec_attr(data, '//ns2:registrationNumber')
					end

					# ПРЕДМЕТ
					text css: '#tabs-2' do |data|
						XGhostCrawler.rec_attr(data, '//ns2:name') || XGhostCrawler.rec_attr(data, '//ns2:subject')
					end

					# ИНН
					inn css: '#tabs-2' do |data|
						XGhostCrawler.rec_attr_by_css(data, '//inn')
					end

					# ЦЕНА
					price css: '#tabs-2' do |data|
						XGhostCrawler.rec_attr_by_css(data, '//initialSum') || XGhostCrawler.rec_attr(data, '//ns2:sum') || XGhostCrawler.rec_attr(data, '//ns2:initialSum')
					end

					# КОНТАКТНОЕ ЛИЦО
					contact_name css: '#tabs-2' do |data|
						(XGhostCrawler.rec_attr_by_css(data, '//lastName') || '') + ' ' + (XGhostCrawler.rec_attr_by_css(data, '//firstName') || '') + ' ' + (XGhostCrawler.rec_attr_by_css(data, '//middleName') || '') + " " + (XGhostCrawler.rec_attr_by_css(data, '//email') || '')
					end					

					# АДРЕС
					address css: '#tabs-2' do |data|
						XGhostCrawler.rec_attr_by_css(data, '//legalAddress')
					end

					# СПОСОБ ПРОВЕДЕНИЯ ЗАКУПКИ
					way_placing css: '#tabs-2' do |data|
						XGhostCrawler.rec_attr_by_css(data, '//purchaseCodeName')
					end
				end

				doc['link'] = link
				pp doc			
				sleep 3	# Задержка в 3 секунды, перед заходом на новую страницу
			rescue => e
				puts e 
				next	
			end
		end	
	end

	####
	def self.rec_attr(data, reg)
		data.gsub!(/<\?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"\?>\n/, '')  # Fix nokogiri
		Nokogiri::XML(data).at(reg).text || ''
		rescue 			
			nil
	end

	def self.rec_attr_by_css(data, reg)
		data.gsub!(/<\?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"\?>\n/, '')
		Nokogiri::XML(data).css(reg).first.text || ''

		rescue
			nil
	end

end

#### START ####
XGhostCrawler.new.crawl