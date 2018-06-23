.PHONY: load-db
load-db :
	docker-compose exec ethicaltree-api rake db:setup
	docker-compose exec ethicaltree-api rake db:schema:load
