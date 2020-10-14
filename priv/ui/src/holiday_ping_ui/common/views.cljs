(ns holiday-ping-ui.common.views
  (:require [re-frame.core :as re-frame]
            [holiday-ping-ui.routes :as routes]))

;; HELPER VIEWS
(defn message-view []
  [:div
   (when-let [message @(re-frame/subscribe [:error-message])]
     [:article.message.is-danger
      [:div.message-body message]])
   (when-let [message @(re-frame/subscribe [:success-message])]
     [:article.message.is-success
      [:div.message-body message]])])

(defn section
  "Wrap the given views in a regular section"
  [& views]
  [:section.section
   (apply vector :div.container views)])

(defn section-size
  "Take the bulma class for size as the first parameter, i.e. :is-half"
  [size & views]
  [:section.section
   [:div.container
    [:div.columns.is-centered
     (apply vector :div.column {:class (name size)} views)]]])

;; APP VIEWS
(defn user-info-view []
  (when @(re-frame/subscribe [:access-token])
    (let [{name :name} @(re-frame/subscribe [:user-info])
          avatar       @(re-frame/subscribe [:avatar])]
      [:header.navbar-item.is-hoverable.has-dropdown
       [:a.navbar-link
        [:img {:src avatar}]]
       [:div.navbar-dropdown
        [:div.navbar-item.has-text-grey name]
        [:hr.navbar-divider]
        [:a.navbar-item {:href "#" :on-click #(re-frame/dispatch [:logout])} "Logout"]]])))

(defn navbar-view
  []
  [:nav.navbar.is-dark
   [:div.container

    [:div.navbar-brand
     [:a.navbar-item.is-size-3.app-title {:href "/"} "Holiday Pinger"]
     [:a.navbar-item.is-hidden-desktop
      {:href "#" :on-click #(re-frame/dispatch [:logout])} "Logout"]]

    [:div.navbar-menu
     [:div.navbar-start
      [:a.navbar-item
       {:href   "https://notamonadtutorial.com"
        :target "_blank"}
       "Blog"]
      [:a.navbar-item
       {:href   "https://github.com/lambdaclass/holiday_pinger"
        :target "_blank"}
       "GitHub"]]
     [:div.navbar-end [user-info-view]]]]])

(defn landing-view
  []
  [section
   [:div.has-text-centered
    [:br]
    [:h1.title.is-1.has-text-primary.landing-title "Don't forget to report your time off again"]
    [:h3.subtitle.is-4 "Holiday Pinger notifies your clients, you enjoy a daiquiri"]
    [:br]
    [:br]
    [:a.button.is-success.is-large
     {:href (routes/url-for :login)}
     [:span.icon [:i.fa.fa-calendar-check-o]]
     [:span "Sign in or register"]]
    [:br]
    [:br]
    [:br]
    [:div.columns.is-centered
     [:div.column.is-two-thirds
      [:figure.image.is-3by2
       [:img.landing-image {:src "/img/calendar.png"}]]]]
    [:br]
    [:br]
    [:h3.subtitle.is-4 "Set up your communication channels, load your calendar and you're golden!"]]])


(defn loading-view
  []
  [:div
   [section-size :is-one-third
    [:div.card
     [:div.card-content
      [:div.has-text-centered
       [:div.subtitle "Loading…"]
       [:a.button.is-medium.is-primary.is-loading
        [:span "Loading"]]]]]]])

(defn not-found-view
  []
  [section
   [:div.has-text-centered
    [:div.subtitle "The page you are looking for was not found."]
    [:div.subtitle [:a {:href "/"} "Take me some place safe."]]]])

(defn breadcrumbs
  [items]
  [:div.breadcrumb.has-succeeds-separator
   [:ul
    (for [[text href] (butlast items)]
      [:li {:key text }[:a {:href href} text]])
    [:li.is-active [:a (-> items last first)]]]])
