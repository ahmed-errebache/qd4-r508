package com.demojunie;

import com.demojunie.product.Product;
import com.demojunie.product.ProductRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class DemoJunieApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoJunieApplication.class, args);
    }

    @Bean
    CommandLineRunner initData(ProductRepository repository) {
        return args -> {
            repository.save(new Product("Clavier", 29.90, 10));
            repository.save(new Product("Souris", 19.90, 20));
            repository.save(new Product("Ecran", 199.00, 5));
        };
    }
}
